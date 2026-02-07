import Tracker.Core.Storage
import Tracker.Core.Types
import Tracker.GUI.Action

namespace Tracker.GUI

inductive ToastLevel where
  | info
  | success
  | error
  deriving Repr, Inhabited

inductive Effect where
  | loadIssues
  | createIssue (title : String) (description : String)
      (priority : Priority) (labels : Array String) (assignee : Option String)
  | updateIssue (id : Nat) (title : String) (description : String)
      (status : Status) (priority : Priority) (labels : Array String) (assignee : Option String)
  | addProgress (id : Nat) (message : String)
  | closeIssue (id : Nat) (comment : Option String)
  | reopenIssue (id : Nat)
  | toast (level : ToastLevel) (message : String)
  deriving Repr, Inhabited

abbrev Dispatch := Action → IO Unit
abbrev ToastSink := ToastLevel → String → IO Unit

private def resolveConfig : IO (Except String (System.FilePath × Storage.Config)) := do
  let cwd ← IO.currentDir
  match ← Storage.findIssuesRoot cwd with
  | none =>
    return .error "No tracker database found from current directory. Run `tracker init`."
  | some root =>
    return .ok (root, { root := root })

private def reloadAndDispatch (dispatch : Dispatch) (root : System.FilePath) (config : Storage.Config)
    (message : String) (selectedIssueId : Option Nat) : IO Unit := do
  let issues ← Storage.loadAllIssues config
  dispatch (.mutationApplied message selectedIssueId root issues)

private def withStorage
    (dispatch : Dispatch)
    (operation : System.FilePath → Storage.Config → IO Unit) : IO Unit := do
  match ← resolveConfig with
  | .error message =>
    dispatch (.mutationFailed message)
  | .ok (root, config) =>
    try
      Storage.ensureReady config
      operation root config
    catch e =>
      dispatch (.mutationFailed s!"{e}")

def runEffects (dispatch : Dispatch) (toastSink : ToastSink) (effects : Array Effect) : IO Unit := do
  for effect in effects do
    match effect with
    | .loadIssues =>
      match ← resolveConfig with
      | .error message =>
        dispatch (.loadFailed message)
      | .ok (root, config) =>
        try
          Storage.ensureReady config
          let issues ← Storage.loadAllIssues config
          dispatch (.loadSucceeded root issues)
        catch e =>
          dispatch (.loadFailed s!"{e}")

    | .createIssue title description priority labels assignee =>
      withStorage dispatch fun root config => do
        let issue ← Storage.createIssue config title description priority labels assignee none
        reloadAndDispatch dispatch root config s!"Created issue #{issue.id}" (some issue.id)

    | .updateIssue id title description status priority labels assignee =>
      withStorage dispatch fun root config => do
        match ← Storage.updateIssue config id (fun issue =>
            { issue with
              title := title
              description := description
              status := status
              priority := priority
              labels := labels
              assignee := assignee
            }) with
        | some _ =>
          reloadAndDispatch dispatch root config s!"Updated issue #{id}" (some id)
        | none =>
          dispatch (.mutationFailed s!"Issue #{id} not found")

    | .addProgress id message =>
      withStorage dispatch fun root config => do
        match ← Storage.addProgress config id message with
        | some _ =>
          reloadAndDispatch dispatch root config s!"Added progress to issue #{id}" (some id)
        | none =>
          dispatch (.mutationFailed s!"Issue #{id} not found")

    | .closeIssue id comment =>
      withStorage dispatch fun root config => do
        match ← Storage.closeIssue config id comment with
        | some _ =>
          reloadAndDispatch dispatch root config s!"Closed issue #{id}" (some id)
        | none =>
          dispatch (.mutationFailed s!"Issue #{id} not found")

    | .reopenIssue id =>
      withStorage dispatch fun root config => do
        match ← Storage.reopenIssue config id with
        | some _ =>
          reloadAndDispatch dispatch root config s!"Reopened issue #{id}" (some id)
        | none =>
          dispatch (.mutationFailed s!"Issue #{id} not found")

    | .toast level message =>
      toastSink level message

end Tracker.GUI
