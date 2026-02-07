/- 
  Tracker storage benchmarks.

  Runs synthetic workloads against Tracker.Core.Storage to identify
  performance hotspots in create/load/list/find/search/update flows.
-/
import Tracker.Core.Storage
import Tracker.Core.Types

namespace TrackerBench

open Tracker
open Tracker.Storage

structure BenchConfig where
  issueCount : Nat := 300
  iterations : Nat := 20
  keepData : Bool := false
  rootDir : System.FilePath := "/tmp/tracker-bench"
  deriving Repr, Inhabited

private partial def deletePathRecursive (path : System.FilePath) : IO Unit := do
  if ← path.isDir then
    for entry in ← path.readDir do
      deletePathRecursive (path / entry.fileName)
    IO.FS.removeDir path
  else if ← path.pathExists then
    IO.FS.removeFile path
  else
    pure ()

private def parseNatArg? (pfx : String) (arg : String) : Option Nat :=
  if arg.startsWith pfx then
    (arg.drop pfx.length).toNat?
  else
    none

private def parseRootArg? (arg : String) : Option System.FilePath :=
  let pfx := "--root="
  if arg.startsWith pfx then
    some <| System.FilePath.mk (arg.drop pfx.length)
  else
    none

private partial def parseArgs (args : List String) (config : BenchConfig := {}) : BenchConfig :=
  match args with
  | [] => config
  | arg :: rest =>
    match parseNatArg? "--issues=" arg with
    | some n => parseArgs rest { config with issueCount := n }
    | none =>
      match parseNatArg? "--iterations=" arg with
      | some n => parseArgs rest { config with iterations := n }
      | none =>
        if arg == "--keep-data" then
          parseArgs rest { config with keepData := true }
        else
          match parseRootArg? arg with
          | some root => parseArgs rest { config with rootDir := root }
          | none => parseArgs rest config

private def measureMs (action : IO α) : IO (α × Nat) := do
  let start ← IO.monoMsNow
  let value ← action
  let elapsed := (← IO.monoMsNow) - start
  pure (value, elapsed)

private def printMetric (label : String) (elapsedMs : Nat) : IO Unit := do
  IO.println s!"  {label}: {elapsedMs}ms"

private def withMetric (label : String) (action : IO α) : IO α := do
  let (value, elapsed) ← measureMs action
  printMetric label elapsed
  pure value

private def seedIssues (config : Config) (count : Nat) : IO Unit := do
  for idx in [:count] do
    let id := idx + 1
    let priority := match id % 4 with
      | 0 => Priority.low
      | 1 => Priority.medium
      | 2 => Priority.high
      | _ => Priority.critical
    let labels := #[s!"l{id % 8}", "bench"]
    let project := some s!"project-{id % 5}"
    let assignee :=
      if id % 3 == 0 then some s!"user-{id % 6}" else none

    let issue ← createIssue config
      s!"benchmark issue {id}"
      s!"Synthetic benchmark issue {id}"
      priority
      labels
      assignee
      project

    if id % 4 == 0 then
      let _ ← addProgress config issue.id s!"progress note {id}"
      pure ()

    if id > 1 && id % 10 == 0 then
      let _ ← addBlockedBy config issue.id (issue.id - 1)
      pure ()

private def benchCreateLoadList (cfg : BenchConfig) (config : Config) : IO Unit := do
  withMetric s!"seed {cfg.issueCount} issues" (seedIssues config cfg.issueCount)
  let issues ← withMetric "loadAllIssues (cold)" (loadAllIssues config)
  IO.println s!"  loaded issues: {issues.size}"

  withMetric s!"listIssues includeAll x{cfg.iterations}" do
    for _ in [:cfg.iterations] do
      let _ ← listIssues config { includeAll := true }
      pure ()

  withMetric s!"listIssues blockedOnly x{cfg.iterations}" do
    for _ in [:cfg.iterations] do
      let _ ← listIssues config { includeAll := true, blockedOnly := true }
      pure ()

private def benchFindSearch (cfg : BenchConfig) (config : Config) : IO Unit := do
  let targetId := if cfg.issueCount == 0 then 1 else (cfg.issueCount / 2 + 1)
  let issues ← loadAllIssues config

  withMetric s!"findIssue #{targetId} x{cfg.iterations * 10}" do
    for _ in [:cfg.iterations * 10] do
      let _ ← findIssue config targetId
      pure ()

  withMetric s!"searchIssuesIn (in-memory) x{cfg.iterations * 10}" do
    for _ in [:cfg.iterations * 10] do
      let _ := searchIssuesIn issues "benchmark"
      pure ()

  withMetric s!"loadAllIssues + search x{cfg.iterations}" do
    for _ in [:cfg.iterations] do
      let loaded ← loadAllIssues config
      let _ := searchIssuesIn loaded "benchmark"
      pure ()

private def benchWrites (cfg : BenchConfig) (config : Config) : IO Unit := do
  let targetId := if cfg.issueCount == 0 then 1 else (cfg.issueCount / 2 + 1)
  let updateIters := cfg.iterations

  withMetric s!"updateIssue #{targetId} x{updateIters}" do
    for i in [:updateIters] do
      let _ ← updateIssue config targetId fun issue =>
        { issue with
          title := s!"{issue.title} (u{i})"
          description := s!"{issue.description}\nupdate {i}" }
      pure ()

  withMetric s!"addProgress #{targetId} x{updateIters}" do
    for i in [:updateIters] do
      let _ ← addProgress config targetId s!"bench progress {i}"
      pure ()

private def printDataFootprint (config : Config) : IO Unit := do
  let path := ledgerFile config
  if ← path.pathExists then
    let bytes := (← IO.FS.readFile path).length
    IO.println s!"  ledger file: {path} ({bytes} bytes)"
  else
    IO.println s!"  ledger file: missing ({path})"

private def runBench (cfg : BenchConfig) : IO Unit := do
  if !cfg.keepData && (← cfg.rootDir.pathExists) then
    deletePathRecursive cfg.rootDir
  IO.FS.createDirAll cfg.rootDir

  let config : Config := { root := cfg.rootDir }
  initIssuesDir cfg.rootDir

  IO.println s!"tracker benchmark: issues={cfg.issueCount}, iterations={cfg.iterations}, root={cfg.rootDir}"

  IO.println "\nCreate/Load/List:"
  benchCreateLoadList cfg config

  IO.println "\nFind/Search:"
  benchFindSearch cfg config

  IO.println "\nWrite Path:"
  benchWrites cfg config

  IO.println "\nFootprint:"
  printDataFootprint config

  if !cfg.keepData then
    deletePathRecursive cfg.rootDir

def printUsage : IO Unit := do
  IO.println "Usage: lake exe tracker_bench -- [--issues=N] [--iterations=N] [--root=/tmp/path] [--keep-data]"
  IO.println "Defaults: --issues=300 --iterations=20 --root=/tmp/tracker-bench"

def main (args : List String) : IO UInt32 := do
  if args.contains "--help" || args.contains "-h" then
    printUsage
    return 0

  let cfg := parseArgs args
  try
    runBench cfg
    return 0
  catch e =>
    IO.eprintln s!"benchmark failed: {e}"
    return 1

end TrackerBench

def main (args : List String) : IO UInt32 := TrackerBench.main args
