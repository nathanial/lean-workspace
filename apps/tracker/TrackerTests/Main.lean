/-
  Tracker Test Suite
-/
import Crucible
import Tracker.Core.Parser
import Tracker.Core.Storage
import Tracker.Core.Types
import Tracker.GUI.Action
import Tracker.GUI.Effect
import Tracker.GUI.Model
import Tracker.GUI.Update
import TrackerTests.TUI

open Crucible
open Tracker.Parser
open Tracker
open Tracker.Storage

testSuite "Tracker.Parser"

/-! ## Frontmatter Parsing -/

test "parse minimal frontmatter" := do
  let content := "---\nid: 1\ntitle: Test Issue\nstatus: open\npriority: medium\ncreated: 2026-01-01\nupdated: 2026-01-01\nlabels: []\nassignee: \nproject: \nblocks: []\nblocked_by: []\n---\n\n# Test Issue\n\n## Description\nTest description\n"
  match parseIssueFile content with
  | .ok parsed =>
    parsed.frontmatter.id ≡ some 1
    parsed.frontmatter.title ≡ some "Test Issue"
    parsed.frontmatter.status ≡ some "open"
    parsed.frontmatter.priority ≡ some "medium"
  | .error e => throwThe IO.Error s!"Parse failed: {e}"

test "parse frontmatter with labels" := do
  let content := "---\nid: 2\ntitle: Bug Fix\nstatus: in-progress\npriority: high\ncreated: 2026-01-01\nupdated: 2026-01-01\nlabels: [bug, urgent]\nassignee: claude\nproject: tracker\nblocks: []\nblocked_by: []\n---\n\n# Bug Fix\n\n## Description\n"
  match parseIssueFile content with
  | .ok parsed =>
    parsed.frontmatter.labels ≡ #["bug", "urgent"]
    parsed.frontmatter.assignee ≡ some "claude"
    parsed.frontmatter.project ≡ some "tracker"
  | .error e => throwThe IO.Error s!"Parse failed: {e}"

test "parse frontmatter with blocks and blocked_by" := do
  let content := "---\nid: 4\ntitle: Blocked Issue\nstatus: open\npriority: medium\ncreated: 2026-01-01\nupdated: 2026-01-01\nlabels: []\nassignee: \nproject: \nblocks: [5, 6]\nblocked_by: [1, 2, 3]\n---\n\n# Blocked Issue\n\n## Description\n"
  match parseIssueFile content with
  | .ok parsed =>
    parsed.frontmatter.blocks ≡ #[5, 6]
    parsed.frontmatter.blockedBy ≡ #[1, 2, 3]
  | .error e => throwThe IO.Error s!"Parse failed: {e}"

test "parse frontmatter with null values" := do
  let content := "---\nid: 5\ntitle: No Assignee\nstatus: open\npriority: medium\ncreated: 2026-01-01\nupdated: 2026-01-01\nlabels: []\nassignee: null\nproject: null\nblocks: []\nblocked_by: []\n---\n\n# No Assignee\n\n## Description\n"
  match parseIssueFile content with
  | .ok parsed =>
    parsed.frontmatter.assignee ≡ none
    parsed.frontmatter.project ≡ none
  | .error e => throwThe IO.Error s!"Parse failed: {e}"

/-! ## Progress Parsing -/

test "parse progress entries" := do
  let content := "---\nid: 7\ntitle: With Progress\nstatus: open\npriority: medium\ncreated: 2026-01-01\nupdated: 2026-01-01\nlabels: []\nassignee: \nproject: \nblocks: []\nblocked_by: []\n---\n\n# With Progress\n\n## Description\nTest\n\n## Progress\n- [2026-01-01T10:00:00] Started work\n- [2026-01-01T11:00:00] Made progress\n"
  match parseIssueFile content with
  | .ok parsed =>
    parsed.progress.size ≡ 2
    parsed.progress[0]!.timestamp ≡ "2026-01-01T10:00:00"
    parsed.progress[0]!.message ≡ "Started work"
  | .error e => throwThe IO.Error s!"Parse failed: {e}"

/-! ## toIssue Conversion -/

test "toIssue applies defaults" := do
  let content := "---\nid: 9\ntitle: Defaults Test\nstatus: open\npriority: high\ncreated: 2026-01-01\nupdated: 2026-01-01\nlabels: [test]\nassignee: \nproject: \nblocks: []\nblocked_by: []\n---\n\n# Defaults Test\n\n## Description\nTest\n"
  match parseIssueFile content with
  | .ok parsed =>
    let issue := toIssue parsed 99 "2026-01-01T00:00:00"
    issue.id ≡ 9
    issue.title ≡ "Defaults Test"
    issue.status ≡ Status.open_
    issue.priority ≡ Priority.high
  | .error e => throwThe IO.Error s!"Parse failed: {e}"

/-! ## Round-trip -/

test "round-trip simple issue" := do
  let content := "---\nid: 10\ntitle: Round Trip Test\nstatus: open\npriority: medium\ncreated: 2026-01-01T00:00:00\nupdated: 2026-01-01T00:00:00\nlabels: []\nassignee: \nproject: \nblocks: []\nblocked_by: []\n---\n\n# Round Trip Test\n\n## Description\nOriginal description\n"
  match parseIssueFile content with
  | .ok parsed1 =>
    let issue := toIssue parsed1 0 "2026-01-01T00:00:00"
    let markdown := issueToMarkdown issue
    match parseIssueFile markdown with
    | .ok parsed2 =>
      let issue2 := toIssue parsed2 0 "2026-01-01T00:00:00"
      issue2.id ≡ issue.id
      issue2.title ≡ issue.title
    | .error e => throwThe IO.Error s!"Second parse failed: {e}"
  | .error e => throwThe IO.Error s!"First parse failed: {e}"

/-! ## Search -/

test "search matches title description and progress" := do
  let issue1 : Issue := {
    id := 1
    title := "Fix parser crash"
    status := Status.open_
    priority := Priority.high
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #[]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := "Tokenizer fails on emoji input"
    progress := #[]
  }
  let issue2 : Issue := {
    id := 2
    title := "UI polish"
    status := Status.open_
    priority := Priority.medium
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #[]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := ""
    progress := #[{ timestamp := "2026-01-02T00:00:00", message := "Investigate parser regression" }]
  }
  let issue3 : Issue := {
    id := 3
    title := "Docs cleanup"
    status := Status.open_
    priority := Priority.low
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #[]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := "Improve onboarding"
    progress := #[]
  }
  let results := searchIssuesIn #[issue1, issue2, issue3] "parser"
  results.size ≡ 2
  results.any (·.id == 1) ≡ true
  results.any (·.id == 2) ≡ true
  results.any (·.id == 3) ≡ false

test "search is case-insensitive" := do
  let issue : Issue := {
    id := 4
    title := "Parser regression"
    status := Status.open_
    priority := Priority.medium
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #[]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := ""
    progress := #[]
  }
  let results := searchIssuesIn #[issue] "PARSER"
  results.size ≡ 1

/-! ## Error Cases -/

test "error on missing frontmatter delimiter" := do
  let content := "id: 1\ntitle: Bad\n"
  match parseIssueFile content with
  | .ok _ => throwThe IO.Error "Should have failed"
  | .error _ => pure ()

test "error on unclosed frontmatter" := do
  let content := "---\nid: 1\ntitle: Unclosed\n"
  match parseIssueFile content with
  | .ok _ => throwThe IO.Error "Should have failed"
  | .error _ => pure ()

testSuite "Tracker.Storage"

private partial def testDeletePathRecursive (path : System.FilePath) : IO Unit := do
  if ← path.isDir then
    for entry in ← path.readDir do
      testDeletePathRecursive (path / entry.fileName)
    IO.FS.removeDir path
  else if ← path.pathExists then
    IO.FS.removeFile path
  else
    pure ()

private def mkIssue (id : Nat) (title : String) : Issue :=
  {
    id := id
    title := title
    status := .open_
    priority := .medium
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #[]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := s!"Description for {title}"
    progress := #[]
  }

test "migrates legacy markdown storage to ledger and deletes .issues" := do
  let root : System.FilePath := "/tmp/tracker_storage_migration_test"
  if ← root.pathExists then
    testDeletePathRecursive root
  IO.FS.createDirAll (root / ".issues")

  let issue1 := { (mkIssue 1 "First issue") with
    labels := #["bug"]
    progress := #[{ timestamp := "2026-01-01T01:00:00", message := "Started" }]
  }
  let issue2 := { (mkIssue 2 "Second issue") with
    blockedBy := #[1]
    project := some "tracker"
  }

  IO.FS.writeFile (root / ".issues" / "0001-first-issue.md") (issueToMarkdown issue1)
  IO.FS.writeFile (root / ".issues" / "0002-second-issue.md") (issueToMarkdown issue2)

  let config : Config := { root := root }
  let migrated ← loadAllIssues config

  migrated.size ≡ 2
  ensure (← (root / "ledger.jsonl").pathExists) "ledger.jsonl should exist after migration"
  ensure (!(← (root / ".issues").isDir)) ".issues directory should be removed after migration"

  let second? := migrated.find? (·.id == 2)
  ensure second?.isSome "Issue #2 should exist after migration"
  match second? with
  | some second =>
    second.blockedBy.contains 1 ≡ true
    second.project ≡ some "tracker"
  | none => pure ()

  let created ← createIssue config "Third issue"
  created.id ≡ 3

  if ← root.pathExists then
    testDeletePathRecursive root

testSuite "Tracker.GUI"

test "GUI effect loadIssues dispatches loadSucceeded from tracker root" := do
  let root : System.FilePath := "/tmp/tracker_gui_load_effect_test"
  if ← root.pathExists then
    testDeletePathRecursive root
  IO.FS.createDirAll root

  let config : Config := { root := root }
  initIssuesDir root
  let _ ← createIssue config "GUI load issue one"
  let _ ← createIssue config "GUI load issue two"

  match ← Tracker.GUI.loadIssuesFromRoot root with
  | .ok (loadedRoot, issues) =>
    loadedRoot.toString ≡ root.toString
    issues.size ≡ 2
  | .error message =>
    throwThe IO.Error s!"Expected load success, got error: {message}"

  if ← root.pathExists then
    testDeletePathRecursive root

test "GUI reducer loadSucceeded normalizes selection and editor drafts" := do
  let issue1 : Issue := {
    id := 10
    title := "First GUI issue"
    status := .open_
    priority := .high
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #["bug", "gui"]
    assignee := some "nathanial"
    project := some "tracker"
    blocks := #[]
    blockedBy := #[]
    description := "First issue description"
    progress := #[]
  }
  let issue2 : Issue := {
    id := 20
    title := "Second GUI issue"
    status := .inProgress
    priority := .medium
    created := "2026-01-02T00:00:00"
    updated := "2026-01-03T00:00:00"
    labels := #["backend"]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := "Second issue description"
    progress := #[]
  }
  let root : System.FilePath := "/tmp/tracker_gui_update_test"

  let (loadingModel, loadEffects) := Tracker.GUI.update Tracker.GUI.Model.initial .loadRequested
  loadingModel.loading ≡ true
  loadEffects.size ≡ 1

  let (loadedModel, afterLoadEffects) :=
    Tracker.GUI.update loadingModel (.loadSucceeded root #[issue1, issue2])
  loadedModel.loading ≡ false
  loadedModel.totalCount ≡ 2
  loadedModel.selectedIssueId ≡ some 10
  loadedModel.editTitle ≡ issue1.title
  loadedModel.editDescription ≡ issue1.description
  loadedModel.editAssignee ≡ "nathanial"
  loadedModel.editPriority ≡ .high
  loadedModel.editStatus ≡ .open_
  afterLoadEffects.size ≡ 1

test "GUI reducer selectIssue updates selection and syncs editor drafts" := do
  let issue1 : Issue := {
    id := 10
    title := "First GUI issue"
    status := .open_
    priority := .high
    created := "2026-01-01T00:00:00"
    updated := "2026-01-01T00:00:00"
    labels := #["bug", "gui"]
    assignee := some "nathanial"
    project := some "tracker"
    blocks := #[]
    blockedBy := #[]
    description := "First issue description"
    progress := #[]
  }
  let issue2 : Issue := {
    id := 20
    title := "Second GUI issue"
    status := .inProgress
    priority := .medium
    created := "2026-01-02T00:00:00"
    updated := "2026-01-03T00:00:00"
    labels := #["backend"]
    assignee := none
    project := none
    blocks := #[]
    blockedBy := #[]
    description := "Second issue description"
    progress := #[]
  }
  let root : System.FilePath := "/tmp/tracker_gui_select_scroll_test"
  let (loadedModel, _) := Tracker.GUI.update Tracker.GUI.Model.initial (.loadSucceeded root #[issue1, issue2])

  let (selectedModel, selectedEffects) :=
    Tracker.GUI.update loadedModel (.selectIssue issue2.id)
  selectedModel.selectedIssueId ≡ some issue2.id
  selectedModel.editTitle ≡ issue2.title
  selectedEffects.size ≡ 0

  let (keyboardModel, _) := Tracker.GUI.update selectedModel (.selectIssue issue1.id)
  keyboardModel.selectedIssueId ≡ some issue1.id
  keyboardModel.editTitle ≡ issue1.title

test "GUI reducer status checkboxes control filtered issue statuses" := do
  let issueOpen := { (mkIssue 1 "Open issue") with
    status := .open_
    project := some "tracker"
  }
  let issueInProgress := { (mkIssue 2 "In-progress issue") with
    status := .inProgress
    project := some "network"
  }
  let issueClosed := { (mkIssue 3 "Closed issue") with
    status := .closed
    project := some "tracker"
  }
  let root : System.FilePath := "/tmp/tracker_gui_status_checkbox_test"
  let (loadedModel, _) :=
    Tracker.GUI.update Tracker.GUI.Model.initial (.loadSucceeded root #[issueOpen, issueInProgress, issueClosed])

  loadedModel.filteredIssues.map (·.id) ≡ #[1, 2]

  let (withClosed, _) := Tracker.GUI.update loadedModel .toggleShowClosed
  withClosed.filteredIssues.map (·.id) ≡ #[1, 2, 3]

  let (activeOff, _) := Tracker.GUI.update withClosed .toggleShowActive
  activeOff.filteredIssues.map (·.id) ≡ #[3]

  let (openOn, _) := Tracker.GUI.update activeOff .toggleShowOpen
  openOn.filteredIssues.map (·.id) ≡ #[1, 3]

  let (inProgressOn, _) := Tracker.GUI.update openOn .toggleShowInProgress
  inProgressOn.filteredIssues.map (·.id) ≡ #[1, 2, 3]

test "GUI reducer project checkboxes include and exclude per-project issues" := do
  let issueTracker := { (mkIssue 11 "Tracker issue") with
    project := some "tracker"
  }
  let issueNetwork := { (mkIssue 12 "Network issue") with
    project := some "network"
  }
  let issueNoProject := mkIssue 13 "General issue"
  let root : System.FilePath := "/tmp/tracker_gui_project_checkbox_test"
  let (loadedModel, _) :=
    Tracker.GUI.update Tracker.GUI.Model.initial
      (.loadSucceeded root #[issueTracker, issueNetwork, issueNoProject])

  loadedModel.filteredIssues.map (·.id) ≡ #[11, 12, 13]

  let (trackerHidden, _) := Tracker.GUI.update loadedModel (.toggleProjectIncluded "tracker")
  trackerHidden.filteredIssues.map (·.id) ≡ #[12, 13]

  let (noProjectHidden, _) := Tracker.GUI.update trackerHidden .toggleNoProjectIncluded
  noProjectHidden.filteredIssues.map (·.id) ≡ #[12]

  let (trackerShown, _) := Tracker.GUI.update noProjectHidden (.toggleProjectIncluded "tracker")
  trackerShown.filteredIssues.map (·.id) ≡ #[11, 12]

  let (networkHidden, _) := Tracker.GUI.update trackerShown (.toggleProjectIncluded "network")
  networkHidden.filteredIssues.map (·.id) ≡ #[11]

def main : IO UInt32 := runAllSuites
