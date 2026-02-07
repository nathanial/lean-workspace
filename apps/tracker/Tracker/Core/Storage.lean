/-
  Ledger-backed storage and migration logic for the issue tracker.
-/
import Std.Data.HashMap
import Tracker.Core.Types
import Tracker.Core.Parser
import Tracker.Core.Util
import Chronos
import Ledger

namespace Tracker.Storage

open Ledger

/-- Configuration for the tracker -/
structure Config where
  /-- Project root directory containing tracker storage. -/
  root : System.FilePath
  deriving Repr, Inhabited

/-- Legacy issues directory name (markdown storage). -/
def issuesDirName : String := ".issues"

/-- Ledger journal file name. -/
def ledgerFileName : String := "ledger.jsonl"

/-- Get the full path to the legacy issues directory. -/
def issuesDir (config : Config) : System.FilePath :=
  config.root / issuesDirName

/-- Get the full path to the Ledger journal file. -/
def ledgerFile (config : Config) : System.FilePath :=
  config.root / ledgerFileName

/-- Check if a directory contains a legacy .issues folder. -/
def hasIssuesDir (dir : System.FilePath) : IO Bool := do
  (dir / issuesDirName).isDir

/-- Check if a directory contains a tracker ledger journal. -/
def hasLedgerFile (dir : System.FilePath) : IO Bool := do
  (dir / ledgerFileName).pathExists

/-- Walk up the directory tree to find tracker storage root.
    Accepts either ledger.jsonl (current) or .issues (legacy, for migration). -/
partial def findIssuesRoot (startDir : System.FilePath) : IO (Option System.FilePath) := do
  if (← hasLedgerFile startDir) || (← hasIssuesDir startDir) then
    return some startDir
  else
    let parent := startDir.parent
    match parent with
    | some p =>
      if p == startDir then return none
      else findIssuesRoot p
    | none => return none

/-- Get current UTC timestamp as ISO 8601 string. -/
def nowIso8601 : IO String := do
  let dt ← Chronos.nowUtc
  return dt.toIso8601

/-- Get current UTC timestamp in milliseconds since epoch. -/
def nowMs : IO Nat := do
  let ts ← Chronos.Timestamp.now
  return ts.seconds.toNat * 1000 + ts.nanoseconds.toNat / 1000000

namespace Attr

-- Issue entity attributes
def issueId : Attribute := .mk ":tracker/issue-id"
def title : Attribute := .mk ":tracker/title"
def status : Attribute := .mk ":tracker/status"
def priority : Attribute := .mk ":tracker/priority"
def created : Attribute := .mk ":tracker/created"
def updated : Attribute := .mk ":tracker/updated"
def description : Attribute := .mk ":tracker/description"
def assignee : Attribute := .mk ":tracker/assignee"
def project : Attribute := .mk ":tracker/project"

-- Label entities and issue-label relation entities
def labelName : Attribute := .mk ":tracker/label-name"
def issueLabelIssue : Attribute := .mk ":tracker/issue-label-issue"
def issueLabelLabel : Attribute := .mk ":tracker/issue-label-label"

-- Progress relation entities
def progressIssue : Attribute := .mk ":tracker/progress-issue"
def progressTimestamp : Attribute := .mk ":tracker/progress-timestamp"
def progressMessage : Attribute := .mk ":tracker/progress-message"

-- Dependency relation entities
def depBlocked : Attribute := .mk ":tracker/dependency-blocked"
def depBlocker : Attribute := .mk ":tracker/dependency-blocker"

end Attr

/-- Parse a Nat out of a Ledger value when possible. -/
private def natFromValue? : Value → Option Nat
  | .int n => if n < 0 then none else some n.toNat
  | _ => none

/-- Parse a String out of a Ledger value when possible. -/
private def stringFromValue? : Value → Option String
  | .string s => some s
  | .keyword s => some s
  | _ => none

/-- Parse an entity reference out of a Ledger value when possible. -/
private def refFromValue? : Value → Option EntityId
  | .ref e => some e
  | _ => none

/-- Sort and deduplicate string arrays (stable semantics for labels). -/
private def dedupStrings (values : Array String) : Array String := Id.run do
  let mut out : Array String := #[]
  for value in values do
    if !out.contains value then
      out := out.push value
  out

/-- Sort and deduplicate Nat arrays. -/
private def dedupNats (values : Array Nat) : Array Nat := Id.run do
  let mut out : Array Nat := #[]
  for value in values do
    if !out.contains value then
      out := out.push value
  out

/-- Recursively delete a file or directory tree. -/
private partial def deletePathRecursive (path : System.FilePath) : IO Unit := do
  if ← path.isDir then
    for entry in ← path.readDir do
      deletePathRecursive (path / entry.fileName)
    IO.FS.removeDir path
  else if ← path.pathExists then
    IO.FS.removeFile path
  else
    pure ()

/-- Load current database snapshot from the tracker journal. -/
private def loadDb (config : Config) : IO Db := do
  let conn ← Ledger.Persist.JSONL.replayJournal (ledgerFile config)
  return conn.db

/-- Persist a successful transaction report to the tracker journal. -/
private def appendReport (path : System.FilePath) (report : TxReport) : IO Unit := do
  let entry : TxLogEntry := {
    txId := report.txId
    txInstant := report.txInstant
    datoms := report.txData
  }
  IO.FS.withFile path .append fun handle => do
    Ledger.Persist.JSONL.appendEntry handle entry

/-- Apply a transaction against current journal state and persist it. -/
private def applyTx (config : Config) (tx : Transaction) : IO (Except TxError Db) := do
  let path := ledgerFile config
  let conn ← Ledger.Persist.JSONL.replayJournal path
  let instant ← nowMs
  match conn.transact tx instant with
  | .error err =>
    return .error err
  | .ok (conn', report) =>
    appendReport path report
    return .ok conn'.db

/-- Set a cardinality-one attribute by retracting any existing value first. -/
private def setOneOps (db : Db) (entity : EntityId) (attr : Attribute) (newValue : Value) : Transaction :=
  let retractOps := match db.getOne entity attr with
    | some oldValue => [TxOp.retract entity attr oldValue]
    | none => []
  retractOps ++ [TxOp.add entity attr newValue]

/-- Clear an optional cardinality-one attribute. -/
private def clearOneOps (db : Db) (entity : EntityId) (attr : Attribute) : Transaction :=
  match db.getOne entity attr with
  | some oldValue => [TxOp.retract entity attr oldValue]
  | none => []

/-- Extract issue ID from an issue entity. -/
private def issueIdOfEntity? (db : Db) (entity : EntityId) : Option Nat := do
  let value ← db.getOne entity Attr.issueId
  natFromValue? value

/-- Build an ID -> issue entity map for all issues in the db. -/
private def issueEntityMap (db : Db) : Std.HashMap Nat EntityId :=
  (db.entitiesWithAttr Attr.issueId).foldl (init := ({} : Std.HashMap Nat EntityId)) fun acc entity =>
    match issueIdOfEntity? db entity with
    | some id => acc.insert id entity
    | none => acc

/-- Resolve an issue entity by numeric issue ID. -/
private def findIssueEntity? (db : Db) (id : Nat) : Option EntityId :=
  (issueEntityMap db)[id]?

private def getStringD (db : Db) (entity : EntityId) (attr : Attribute) (fallback : String) : String :=
  match db.getOne entity attr with
  | some value => (stringFromValue? value).getD fallback
  | none => fallback

private def getString? (db : Db) (entity : EntityId) (attr : Attribute) : Option String := do
  let value ← db.getOne entity attr
  stringFromValue? value

private def getStatusD (db : Db) (entity : EntityId) (fallback : Status := .open_) : Status :=
  match getString? db entity Attr.status with
  | some s => (Status.fromString? s).getD fallback
  | none => fallback

private def getPriorityD (db : Db) (entity : EntityId) (fallback : Priority := .medium) : Priority :=
  match getString? db entity Attr.priority with
  | some s => (Priority.fromString? s).getD fallback
  | none => fallback

/-- Reconstruct labels for an issue by traversing issue-label relation entities. -/
private def loadIssueLabels (db : Db) (issueEntity : EntityId) : Array String := Id.run do
  let relEntities := db.referencingViaAttr issueEntity Attr.issueLabelIssue
  let mut labels : Array String := #[]
  for rel in relEntities do
    if let some refVal := db.getOne rel Attr.issueLabelLabel then
      if let some labelEntity := refFromValue? refVal then
        if let some name := getString? db labelEntity Attr.labelName then
          if !labels.contains name then
            labels := labels.push name
  return labels.qsort (fun a b => a < b)

/-- Reconstruct progress entries for an issue by traversing progress relation entities. -/
private def loadIssueProgress (db : Db) (issueEntity : EntityId) : Array ProgressEntry := Id.run do
  let relEntities := db.referencingViaAttr issueEntity Attr.progressIssue
  let mut entries : Array ProgressEntry := #[]
  for rel in relEntities do
    match getString? db rel Attr.progressTimestamp, getString? db rel Attr.progressMessage with
    | some timestamp, some message =>
      entries := entries.push { timestamp, message }
    | _, _ =>
      pure ()
  return entries.qsort (fun a b => a.timestamp < b.timestamp)

/-- Reconstruct dependency lists for an issue. -/
private def loadIssueDeps (db : Db) (issueEntity : EntityId) : Array Nat × Array Nat := Id.run do
  let mut blockedBy : Array Nat := #[]
  let mut blocks : Array Nat := #[]

  let blockedDeps := db.referencingViaAttr issueEntity Attr.depBlocked
  for rel in blockedDeps do
    if let some refVal := db.getOne rel Attr.depBlocker then
      if let some blockerEntity := refFromValue? refVal then
        if let some blockerId := issueIdOfEntity? db blockerEntity then
          if !blockedBy.contains blockerId then
            blockedBy := blockedBy.push blockerId

  let blockerDeps := db.referencingViaAttr issueEntity Attr.depBlocker
  for rel in blockerDeps do
    if let some refVal := db.getOne rel Attr.depBlocked then
      if let some blockedEntity := refFromValue? refVal then
        if let some blockedId := issueIdOfEntity? db blockedEntity then
          if !blocks.contains blockedId then
            blocks := blocks.push blockedId

  return (blocks.qsort (fun a b => a < b), blockedBy.qsort (fun a b => a < b))

/-- Reconstruct a full Issue record from an issue entity. -/
private def issueFromEntity (db : Db) (issueEntity : EntityId) (id : Nat) : Issue :=
  let title := getStringD db issueEntity Attr.title "Untitled"
  let status := getStatusD db issueEntity
  let priority := getPriorityD db issueEntity
  let created := getStringD db issueEntity Attr.created ""
  let updated := getStringD db issueEntity Attr.updated ""
  let description := getStringD db issueEntity Attr.description ""
  let assignee := getString? db issueEntity Attr.assignee
  let project := getString? db issueEntity Attr.project
  let labels := loadIssueLabels db issueEntity
  let progress := loadIssueProgress db issueEntity
  let (blocks, blockedBy) := loadIssueDeps db issueEntity
  {
    id := id
    title := title
    status := status
    priority := priority
    created := created
    updated := updated
    labels := labels
    assignee := assignee
    project := project
    blocks := blocks
    blockedBy := blockedBy
    description := description
    progress := progress
  }

/-- Load all issue entities and decode them as tracker issues. -/
private def loadAllIssuesFromDb (db : Db) : Array Issue := Id.run do
  let map := issueEntityMap db
  let mut issues : Array Issue := #[]
  for (id, issueEntity) in map.toList do
    issues := issues.push (issueFromEntity db issueEntity id)
  return issues.qsort (fun a b => a.id < b.id)

/-- Gather legacy markdown issue files from .issues. -/
private def listLegacyIssueFiles (config : Config) : IO (Array System.FilePath) := do
  let dir := issuesDir config
  if !(← dir.isDir) then
    return #[]
  let entries ← dir.readDir
  let files := entries.filter fun e =>
    e.fileName.endsWith ".md" && e.fileName != "README.md"
  return files.map (dir / ·.fileName)

/-- Parse all legacy markdown issues. Throws on malformed files. -/
private def parseLegacyIssues (config : Config) : IO (Array Issue) := do
  let files ← listLegacyIssueFiles config
  let fallbackTs ← nowIso8601
  let mut issues : Array Issue := #[]
  for file in files do
    let content ← IO.FS.readFile file
    match Parser.parseIssueFile content with
    | .ok parsed =>
      issues := issues.push (Parser.toIssue parsed 0 fallbackTs)
    | .error err =>
      throw (IO.userError s!"Failed to parse legacy issue file {file}: {err}")
  return issues.qsort (fun a b => a.id < b.id)

private def dependencyKey (blockedId blockerId : Nat) : String :=
  s!"{blockedId}->{blockerId}"

/-- Build a single issue's base datoms (excluding labels/progress/dependencies). -/
private def issueBaseOps (issueEntity : EntityId) (issue : Issue) : Transaction :=
  let base : Transaction := [
    TxOp.add issueEntity Attr.issueId (.int (Int.ofNat issue.id)),
    TxOp.add issueEntity Attr.title (.string issue.title),
    TxOp.add issueEntity Attr.status (.string issue.status.toString),
    TxOp.add issueEntity Attr.priority (.string issue.priority.toString),
    TxOp.add issueEntity Attr.created (.string issue.created),
    TxOp.add issueEntity Attr.updated (.string issue.updated),
    TxOp.add issueEntity Attr.description (.string issue.description)
  ]
  let withAssignee := match issue.assignee with
    | some assignee => base ++ [TxOp.add issueEntity Attr.assignee (.string assignee)]
    | none => base
  match issue.project with
  | some project => withAssignee ++ [TxOp.add issueEntity Attr.project (.string project)]
  | none => withAssignee

/-- Migrate legacy markdown issues into normalized Ledger storage, then delete .issues. -/
private def migrateLegacyIssues (config : Config) : IO Unit := do
  let issues ← parseLegacyIssues config

  -- Build one migration transaction from parsed issues.
  let tx := Id.run do
    let mut db := Db.empty
    let mut tx : Transaction := []
    let mut issueEntities : Std.HashMap Nat EntityId := {}
    let mut labelEntities : Std.HashMap String EntityId := {}
    let mut seenDeps : Std.HashMap String Unit := {}

    -- First pass: issue entities and scalar attributes.
    for issue in issues do
      let (issueEntity, db') := db.allocEntityId
      db := db'
      issueEntities := issueEntities.insert issue.id issueEntity
      tx := tx ++ issueBaseOps issueEntity issue

    -- Second pass: labels, progress, and dependencies.
    for issue in issues do
      let some issueEntity := issueEntities[issue.id]?
        | continue

      for label in dedupStrings issue.labels do
        let (labelEntity, db', labelEntities', tx') :=
          match labelEntities[label]? with
          | some existing =>
            (existing, db, labelEntities, tx)
          | none =>
            let (newLabelEntity, db') := db.allocEntityId
            let labelEntities' := labelEntities.insert label newLabelEntity
            let tx' := tx ++ [TxOp.add newLabelEntity Attr.labelName (.string label)]
            (newLabelEntity, db', labelEntities', tx')

        db := db'
        labelEntities := labelEntities'
        tx := tx'

        let (relationEntity, db'') := db.allocEntityId
        db := db''
        tx := tx ++ [
          TxOp.add relationEntity Attr.issueLabelIssue (.ref issueEntity),
          TxOp.add relationEntity Attr.issueLabelLabel (.ref labelEntity)
        ]

      for progress in issue.progress do
        let (progressEntity, db') := db.allocEntityId
        db := db'
        tx := tx ++ [
          TxOp.add progressEntity Attr.progressIssue (.ref issueEntity),
          TxOp.add progressEntity Attr.progressTimestamp (.string progress.timestamp),
          TxOp.add progressEntity Attr.progressMessage (.string progress.message)
        ]

      -- Dependencies may exist in either blockedBy or blocks fields. Use a key set to dedupe.
      for blockerId in dedupNats issue.blockedBy do
        if let some blockerEntity := issueEntities[blockerId]? then
          let key := dependencyKey issue.id blockerId
          if !seenDeps.contains key then
            seenDeps := seenDeps.insert key ()
            let (depEntity, db') := db.allocEntityId
            db := db'
            tx := tx ++ [
              TxOp.add depEntity Attr.depBlocked (.ref issueEntity),
              TxOp.add depEntity Attr.depBlocker (.ref blockerEntity)
            ]

      for blockedId in dedupNats issue.blocks do
        if let some blockedEntity := issueEntities[blockedId]? then
          let key := dependencyKey blockedId issue.id
          if !seenDeps.contains key then
            seenDeps := seenDeps.insert key ()
            let (depEntity, db') := db.allocEntityId
            db := db'
            tx := tx ++ [
              TxOp.add depEntity Attr.depBlocked (.ref blockedEntity),
              TxOp.add depEntity Attr.depBlocker (.ref issueEntity)
            ]

    tx

  let path := ledgerFile config
  let conn ← Ledger.Persist.JSONL.replayJournal path
  let instant ← nowMs
  match conn.transact tx instant with
  | .error err =>
    throw (IO.userError s!"Failed to migrate legacy issues to Ledger: {err}")
  | .ok (conn', report) =>
    appendReport path report
    let migratedIssues := loadAllIssuesFromDb conn'.db
    if migratedIssues.size != issues.size then
      throw (IO.userError s!"Migration verification failed: expected {issues.size}, got {migratedIssues.size}")

  let legacyDir := issuesDir config
  if ← legacyDir.isDir then
    deletePathRecursive legacyDir

/-- Ensure storage is ready:
    - if ledger exists: ready
    - else if legacy markdown exists: migrate
    - else fail and ask user to run init
-/
def ensureReady (config : Config) : IO Unit := do
  if ← (ledgerFile config).pathExists then
    return
  if ← hasIssuesDir config.root then
    migrateLegacyIssues config
    return
  throw (IO.userError "No tracker database found. Run 'tracker init' first.")

/-- Initialize tracker storage at project root.
    If legacy .issues exists, migration is performed automatically.
-/
def initIssuesDir (root : System.FilePath) : IO Unit := do
  let config : Config := { root := root }
  let path := ledgerFile config
  if ← path.pathExists then
    throw (IO.userError s!"Tracker database already exists: {path}")
  if ← hasIssuesDir root then
    migrateLegacyIssues config
  else
    IO.FS.writeFile path ""

/-- Get next available issue ID from existing issues. -/
def nextIssueId (config : Config) : IO Nat := do
  ensureReady config
  let db ← loadDb config
  let mut maxId : Nat := 0
  for issue in loadAllIssuesFromDb db do
    maxId := max maxId issue.id
  return maxId + 1

/-- Load all issues from ledger storage. -/
def loadAllIssues (config : Config) : IO (Array Issue) := do
  ensureReady config
  let db ← loadDb config
  return loadAllIssuesFromDb db

/-- Find an issue by ID. -/
def findIssue (config : Config) (id : Nat) : IO (Option Issue) := do
  let issues ← loadAllIssues config
  return issues.find? (·.id == id)

/-- Update an existing issue's scalar fields and labels. -/
def updateIssue (config : Config) (id : Nat) (modify : Issue → Issue) : IO (Option Issue) := do
  ensureReady config
  let db ← loadDb config

  let some issueEntity := findIssueEntity? db id
    | return none

  let oldIssue := issueFromEntity db issueEntity id
  let timestamp ← nowIso8601
  let newIssue := modify { oldIssue with updated := timestamp }

  let mut tx : Transaction := []

  tx := tx ++ setOneOps db issueEntity Attr.title (.string newIssue.title)
  tx := tx ++ setOneOps db issueEntity Attr.status (.string newIssue.status.toString)
  tx := tx ++ setOneOps db issueEntity Attr.priority (.string newIssue.priority.toString)
  tx := tx ++ setOneOps db issueEntity Attr.updated (.string newIssue.updated)
  tx := tx ++ setOneOps db issueEntity Attr.description (.string newIssue.description)

  match newIssue.assignee with
  | some assignee =>
    tx := tx ++ setOneOps db issueEntity Attr.assignee (.string assignee)
  | none =>
    tx := tx ++ clearOneOps db issueEntity Attr.assignee

  match newIssue.project with
  | some project =>
    tx := tx ++ setOneOps db issueEntity Attr.project (.string project)
  | none =>
    tx := tx ++ clearOneOps db issueEntity Attr.project

  let oldRelEntities := db.referencingViaAttr issueEntity Attr.issueLabelIssue
  let oldLabelPairs := oldRelEntities.filterMap fun rel =>
    match db.getOne rel Attr.issueLabelLabel with
    | some refVal =>
      match refFromValue? refVal with
      | some labelEntity =>
        match getString? db labelEntity Attr.labelName with
        | some label => some (rel, label)
        | none => none
      | none => none
    | none => none

  let oldLabels := oldLabelPairs.map Prod.snd |>.toArray
  let newLabels := dedupStrings newIssue.labels

  -- Remove relations for labels no longer present.
  for (relEntity, label) in oldLabelPairs do
    if !newLabels.contains label then
      tx := tx ++ [.retractEntity (.id relEntity)]

  -- Add relations for newly-added labels.
  let mut allocDb := db
  let mut localLabelEntities : Std.HashMap String EntityId := {}

  for label in newLabels do
    if !oldLabels.contains label then
      let (labelEntity, allocDb', localLabelEntities', tx') :=
        match localLabelEntities[label]? with
        | some entity =>
          (entity, allocDb, localLabelEntities, tx)
        | none =>
          match db.entityWithAttrValue Attr.labelName (.string label) with
          | some existing =>
            (existing, allocDb, localLabelEntities.insert label existing, tx)
          | none =>
            let (newEntity, allocDb') := allocDb.allocEntityId
            let tx' := tx ++ [TxOp.add newEntity Attr.labelName (.string label)]
            (newEntity, allocDb', localLabelEntities.insert label newEntity, tx')

      allocDb := allocDb'
      localLabelEntities := localLabelEntities'
      tx := tx'

      let (relEntity, allocDb'') := allocDb.allocEntityId
      allocDb := allocDb''
      tx := tx ++ [
        TxOp.add relEntity Attr.issueLabelIssue (.ref issueEntity),
        TxOp.add relEntity Attr.issueLabelLabel (.ref labelEntity)
      ]

  if tx.isEmpty then
    return some newIssue

  match ← applyTx config tx with
  | .error err =>
    throw (IO.userError s!"Failed to update issue #{id}: {err}")
  | .ok _ =>
    return (← findIssue config id)

/-- Create a new issue. -/
def createIssue (config : Config) (title : String) (description : String := "")
    (priority : Priority := .medium) (labels : Array String := #[])
    (assignee : Option String := none) (project : Option String := none) : IO Issue := do
  ensureReady config
  let db ← loadDb config
  let id ← nextIssueId config
  let timestamp ← nowIso8601

  let mut allocDb := db
  let (issueEntity, allocDb') := allocDb.allocEntityId
  allocDb := allocDb'

  let mut tx : Transaction := issueBaseOps issueEntity {
    id := id
    title := title
    status := .open_
    priority := priority
    created := timestamp
    updated := timestamp
    labels := #[]
    assignee := assignee
    project := project
    blocks := #[]
    blockedBy := #[]
    description := description
    progress := #[]
  }

  let mut localLabelEntities : Std.HashMap String EntityId := {}
  for label in dedupStrings labels do
    let (labelEntity, allocDb', localLabelEntities', tx') :=
      match localLabelEntities[label]? with
      | some entity =>
        (entity, allocDb, localLabelEntities, tx)
      | none =>
        match db.entityWithAttrValue Attr.labelName (.string label) with
        | some existing =>
          (existing, allocDb, localLabelEntities.insert label existing, tx)
        | none =>
          let (newEntity, allocDb') := allocDb.allocEntityId
          let tx' := tx ++ [TxOp.add newEntity Attr.labelName (.string label)]
          (newEntity, allocDb', localLabelEntities.insert label newEntity, tx')

    allocDb := allocDb'
    localLabelEntities := localLabelEntities'
    tx := tx'

    let (relEntity, allocDb'') := allocDb.allocEntityId
    allocDb := allocDb''
    tx := tx ++ [
      TxOp.add relEntity Attr.issueLabelIssue (.ref issueEntity),
      TxOp.add relEntity Attr.issueLabelLabel (.ref labelEntity)
    ]

  match ← applyTx config tx with
  | .error err =>
    throw (IO.userError s!"Failed to create issue: {err}")
  | .ok _ =>
    match (← findIssue config id) with
    | some issue => return issue
    | none => throw (IO.userError s!"Created issue #{id}, but failed to reload it")

/-- Add a progress entry to an issue. -/
def addProgress (config : Config) (id : Nat) (message : String) : IO (Option Issue) := do
  ensureReady config
  let db ← loadDb config
  let some issueEntity := findIssueEntity? db id
    | return none

  let timestamp ← nowIso8601
  let (progressEntity, _) := db.allocEntityId
  let tx : Transaction :=
    setOneOps db issueEntity Attr.updated (.string timestamp) ++ [
      TxOp.add progressEntity Attr.progressIssue (.ref issueEntity),
      TxOp.add progressEntity Attr.progressTimestamp (.string timestamp),
      TxOp.add progressEntity Attr.progressMessage (.string message)
    ]

  match ← applyTx config tx with
  | .error err => throw (IO.userError s!"Failed to add progress to issue #{id}: {err}")
  | .ok _ => return (← findIssue config id)

/-- Close an issue with optional closing comment. -/
def closeIssue (config : Config) (id : Nat) (comment : Option String := none) : IO (Option Issue) := do
  ensureReady config
  let db ← loadDb config
  let some issueEntity := findIssueEntity? db id
    | return none

  let timestamp ← nowIso8601
  let mut tx : Transaction := []
  tx := tx ++ setOneOps db issueEntity Attr.status (.string Status.closed.toString)
  tx := tx ++ setOneOps db issueEntity Attr.updated (.string timestamp)

  match comment with
  | some msg =>
    let (progressEntity, _) := db.allocEntityId
    tx := tx ++ [
      TxOp.add progressEntity Attr.progressIssue (.ref issueEntity),
      TxOp.add progressEntity Attr.progressTimestamp (.string timestamp),
      TxOp.add progressEntity Attr.progressMessage (.string s!"Closed: {msg}")
    ]
  | none =>
    pure ()

  match ← applyTx config tx with
  | .error err => throw (IO.userError s!"Failed to close issue #{id}: {err}")
  | .ok _ => return (← findIssue config id)

/-- Reopen a closed issue. -/
def reopenIssue (config : Config) (id : Nat) : IO (Option Issue) := do
  ensureReady config
  let db ← loadDb config
  let some issueEntity := findIssueEntity? db id
    | return none

  let timestamp ← nowIso8601
  let (progressEntity, _) := db.allocEntityId
  let tx : Transaction :=
    setOneOps db issueEntity Attr.status (.string Status.open_.toString) ++
    setOneOps db issueEntity Attr.updated (.string timestamp) ++ [
      TxOp.add progressEntity Attr.progressIssue (.ref issueEntity),
      TxOp.add progressEntity Attr.progressTimestamp (.string timestamp),
      TxOp.add progressEntity Attr.progressMessage (.string "Reopened")
    ]

  match ← applyTx config tx with
  | .error err => throw (IO.userError s!"Failed to reopen issue #{id}: {err}")
  | .ok _ => return (← findIssue config id)

/-- Add a dependency (issue `id` is blocked by issue `blockedById`). -/
def addBlockedBy (config : Config) (id : Nat) (blockedById : Nat) : IO (Option Issue) := do
  ensureReady config
  let db ← loadDb config

  let some issueEntity := findIssueEntity? db id
    | return none
  let some blockerEntity := findIssueEntity? db blockedById
    | return none

  let depEntities := db.referencingViaAttr issueEntity Attr.depBlocked
  let alreadyExists := depEntities.any fun rel =>
    match db.getOne rel Attr.depBlocker with
    | some value => refFromValue? value == some blockerEntity
    | none => false

  if alreadyExists then
    return (← findIssue config id)

  let (depEntity, _) := db.allocEntityId
  let tx : Transaction := [
    TxOp.add depEntity Attr.depBlocked (.ref issueEntity),
    TxOp.add depEntity Attr.depBlocker (.ref blockerEntity)
  ]

  match ← applyTx config tx with
  | .error err => throw (IO.userError s!"Failed to add dependency for issue #{id}: {err}")
  | .ok _ => return (← findIssue config id)

/-- Remove a dependency relation if present. -/
def removeBlockedBy (config : Config) (id : Nat) (blockedById : Nat) : IO (Option Issue) := do
  ensureReady config
  let db ← loadDb config

  let some issueEntity := findIssueEntity? db id
    | return none

  let blockerEntity? := findIssueEntity? db blockedById
  let depEntities := db.referencingViaAttr issueEntity Attr.depBlocked

  let removals := depEntities.filter fun rel =>
    match blockerEntity?, db.getOne rel Attr.depBlocker with
    | some blockerEntity, some value =>
      refFromValue? value == some blockerEntity
    | _, _ =>
      false

  let tx : Transaction := removals.map (fun rel => TxOp.retractEntity (.id rel))

  if tx.isEmpty then
    return (← findIssue config id)

  match ← applyTx config tx with
  | .error err => throw (IO.userError s!"Failed to remove dependency for issue #{id}: {err}")
  | .ok _ => return (← findIssue config id)

/-- Filter for listing issues. -/
structure ListFilter where
  status : Option Status := none
  label : Option String := none
  assignee : Option String := none
  project : Option String := none
  blockedOnly : Bool := false
  includeAll : Bool := false
  deriving Repr, Inhabited

/-- List issues with optional filtering. -/
def listIssues (config : Config) (filter : ListFilter := {}) : IO (Array Issue) := do
  let issues ← loadAllIssues config
  let filtered := issues.filter fun issue =>
    let statusOk := match filter.status with
      | some s => issue.status == s
      | none => filter.includeAll || issue.status.isOpen
    let labelOk := match filter.label with
      | some l => issue.labels.contains l
      | none => true
    let assigneeOk := match filter.assignee with
      | some a => issue.assignee == some a
      | none => true
    let projectOk := match filter.project with
      | some p => issue.project == some p
      | none => true
    let blockedOk := !filter.blockedOnly || issue.isBlocked
    statusOk && labelOk && assigneeOk && projectOk && blockedOk
  return filtered

/-- Search issues by keyword across title, description, and progress notes. -/
def searchIssuesIn (issues : Array Issue) (query : String) : Array Issue :=
  let term := Util.trim query |>.toLower
  if term.isEmpty then
    #[]
  else
    let containsTerm (text : String) : Bool :=
      Util.containsSubstr (text.toLower) term
    let matchesTerm (issue : Issue) : Bool :=
      containsTerm issue.title ||
      containsTerm issue.description ||
      issue.progress.any (fun entry => containsTerm entry.message)
    issues.filter matchesTerm

/-- Delete an issue and its related relation entities. -/
def deleteIssue (config : Config) (id : Nat) : IO Bool := do
  ensureReady config
  let db ← loadDb config

  let some issueEntity := findIssueEntity? db id
    | return false

  let progressEntities := db.referencingViaAttr issueEntity Attr.progressIssue
  let labelRelEntities := db.referencingViaAttr issueEntity Attr.issueLabelIssue
  let depBlockedEntities := db.referencingViaAttr issueEntity Attr.depBlocked
  let depBlockerEntities := db.referencingViaAttr issueEntity Attr.depBlocker

  let mut deleteTargets : Array EntityId := #[issueEntity]
  for entity in progressEntities do
    if !deleteTargets.contains entity then
      deleteTargets := deleteTargets.push entity
  for entity in labelRelEntities do
    if !deleteTargets.contains entity then
      deleteTargets := deleteTargets.push entity
  for entity in depBlockedEntities do
    if !deleteTargets.contains entity then
      deleteTargets := deleteTargets.push entity
  for entity in depBlockerEntities do
    if !deleteTargets.contains entity then
      deleteTargets := deleteTargets.push entity

  let tx := deleteTargets.map (fun entity => TxOp.retractEntity (.id entity)) |>.toList

  match ← applyTx config tx with
  | .error err => throw (IO.userError s!"Failed to delete issue #{id}: {err}")
  | .ok _ => return true

/-- Check if an issue is effectively blocked (any blocker is still open). -/
def isEffectivelyBlocked (issue : Issue) (allIssues : Array Issue) : Bool :=
  issue.blockedBy.any fun blockerId =>
    match allIssues.find? (·.id == blockerId) with
    | some blocker => blocker.status != .closed
    | none => false

end Tracker.Storage
