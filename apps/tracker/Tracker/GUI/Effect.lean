import Tracker.Core.Storage
import Tracker.GUI.Action

namespace Tracker.GUI

inductive Effect where
  | loadIssues
  deriving Repr, Inhabited

abbrev Dispatch := Action → IO Unit

private def loadIssuesIO : IO (Except String (System.FilePath × Array Issue)) := do
  let cwd ← IO.currentDir
  match ← Storage.findIssuesRoot cwd with
  | none =>
    return .error "No tracker database found from current directory. Run `tracker init`."
  | some root =>
    let config : Storage.Config := { root := root }
    try
      Storage.ensureReady config
      let issues ← Storage.loadAllIssues config
      return .ok (root, issues)
    catch e =>
      return .error s!"{e}"

def runEffects (dispatch : Dispatch) (effects : Array Effect) : IO Unit := do
  for effect in effects do
    match effect with
    | .loadIssues =>
      match ← loadIssuesIO with
      | .ok (root, issues) =>
        dispatch (.loadSucceeded root issues)
      | .error message =>
        dispatch (.loadFailed message)

end Tracker.GUI
