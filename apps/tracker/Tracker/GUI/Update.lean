import Afferent.Arbor
import Tracker.GUI.Action
import Tracker.GUI.Effect
import Tracker.GUI.Model

namespace Tracker.GUI

private def focusPrevPane : FocusPane → FocusPane
  | .issues => .actions
  | .detail => .issues
  | .actions => .detail

private def focusNextPane : FocusPane → FocusPane
  | .issues => .detail
  | .detail => .actions
  | .actions => .issues

def actionFromKey (key : Afferent.Arbor.Key) : Option Action :=
  match key with
  | .tab => some .focusNext
  | .left => some .focusPrev
  | .right => some .focusNext
  | .up => some .selectPrev
  | .down => some .selectNext
  | .char 'h' => some .focusPrev
  | .char 'l' => some .focusNext
  | .char 'k' => some .selectPrev
  | .char 'j' => some .selectNext
  | .char 'f' => some .statusFilterNext
  | .char 'b' => some .toggleBlockedOnly
  | .char 'r' => some .refresh
  | _ => none

private def setStatus (model : Model) (message : String) : Model :=
  { model with status := message }

private def withNormalizedSelection (model : Model) : Model :=
  model.normalizeSelection

private def visibleIds (model : Model) : Array Nat :=
  model.filteredIssues.map (·.id)

private def indexOfId (ids : Array Nat) (id : Nat) : Option Nat := Id.run do
  for i in [:ids.size] do
    if ids[i]! == id then
      return some i
  return none

private def selectById (model : Model) (id : Nat) : Model :=
  let next := { model with selectedIssueId := some id }
  let withSelection := withNormalizedSelection next
  setStatus withSelection s!"Selected issue #{id}"

private def selectRelative (model : Model) (forward : Bool) : Model :=
  let ids := visibleIds model
  if ids.isEmpty then
    model
  else
    let currentPos :=
      match model.selectedIssueId with
      | some id => indexOfId ids id
      | none => none
    let nextPos :=
      match currentPos with
      | none => 0
      | some pos =>
        if forward then
          (pos + 1) % ids.size
        else
          if pos == 0 then ids.size - 1 else pos - 1
    if h : nextPos < ids.size then
      selectById model ids[nextPos]
    else
      model

private def beginLoad (model : Model) (message : String) : Model × Array Effect :=
  ({ model with loading := true, error := none, status := message }, #[.loadIssues])

private def applyNonKeyAction (model : Model) (action : Action) : Model × Array Effect :=
  match action with
  | .loadRequested =>
    beginLoad model "Loading issues..."
  | .refresh =>
    beginLoad model "Refreshing issues..."
  | .loadSucceeded root issues =>
    let next := {
      model with
      root := some root
      issues := issues
      loading := false
      error := none
      status := s!"Loaded {issues.size} issues"
    }
    (withNormalizedSelection next, #[])
  | .loadFailed message =>
    ({ model with loading := false, error := some message, status := "Failed to load issues" }, #[])
  | .focusPrev =>
    (setStatus { model with focusPane := focusPrevPane model.focusPane } "Focus moved", #[])
  | .focusNext =>
    (setStatus { model with focusPane := focusNextPane model.focusPane } "Focus moved", #[])
  | .focusSet pane =>
    (setStatus { model with focusPane := pane } s!"Focus: {pane.label}", #[])
  | .selectPrev =>
    (selectRelative model false, #[])
  | .selectNext =>
    (selectRelative model true, #[])
  | .selectIssue id =>
    (selectById model id, #[])
  | .queryChanged query =>
    let next := withNormalizedSelection { model with query := query }
    (setStatus next s!"Search: {query}", #[])
  | .statusFilterNext =>
    let next := withNormalizedSelection { model with statusFilter := model.statusFilter.next }
    (setStatus next s!"Status filter: {next.statusFilter.label}", #[])
  | .toggleBlockedOnly =>
    let next := withNormalizedSelection { model with blockedOnly := !model.blockedOnly }
    (setStatus next (if next.blockedOnly then "Blocked-only filter on" else "Blocked-only filter off"), #[])
  | .keyInput _ =>
    (model, #[])

def update (model : Model) (action : Action) : Model × Array Effect :=
  match action with
  | .keyInput key =>
    match actionFromKey key with
    | some translated => applyNonKeyAction model translated
    | none => (model, #[])
  | nonKey =>
    applyNonKeyAction model nonKey

end Tracker.GUI
