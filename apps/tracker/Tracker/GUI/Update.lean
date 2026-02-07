import Afferent.Arbor
import Tracker.Core.Types
import Tracker.Core.Util
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
  | .char 'u' => some .saveEdits
  | .char 'p' => some .addProgressSubmitted
  | _ => none

private def setStatus (model : Model) (message : String) : Model :=
  { model with status := message }

private def withNormalizedSelection (model : Model) : Model :=
  model.normalizeSelection

private def withSyncedEditor (model : Model) : Model :=
  model.syncEditorFromSelection

private def visibleIds (model : Model) : Array Nat :=
  model.filteredIssues.map (·.id)

private def indexOfId (ids : Array Nat) (id : Nat) : Option Nat := Id.run do
  for i in [:ids.size] do
    if ids[i]! == id then
      return some i
  return none

private def selectById (model : Model) (id : Nat) : Model :=
  let next := { model with selectedIssueId := some id }
  let withSelection := withSyncedEditor <| withNormalizedSelection next
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

private def beginMutation (model : Model) (message : String) : Model :=
  { model with loading := true, error := none, status := message }

private def createTitleValid (model : Model) : Bool :=
  !(Util.trim model.createTitle).isEmpty

private def canMutate (model : Model) : Bool :=
  !model.loading

private def selectedIssueId? (model : Model) : Option Nat :=
  model.selectedIssueId

private def clearPostMutationDrafts (model : Model) : Model :=
  { model with
    createTitle := ""
    createDescription := ""
    createAssignee := ""
    createLabels := ""
    createPriority := .medium
    progressMessage := ""
    closeComment := ""
  }

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
    let synced := withSyncedEditor <| withNormalizedSelection next
    (synced, #[.toast .info s!"Loaded {issues.size} issues"])

  | .loadFailed message =>
    ({ model with loading := false, error := some message, status := "Failed to load issues" },
      #[.toast .error message])

  | .mutationApplied message selectedIssueId root issues =>
    let selected :=
      match selectedIssueId with
      | some id => some id
      | none => model.selectedIssueId
    let next := {
      model with
      root := some root
      issues := issues
      selectedIssueId := selected
      loading := false
      error := none
      status := message
    }
    let normalized := withSyncedEditor <| withNormalizedSelection next
    (clearPostMutationDrafts normalized, #[.toast .success message])

  | .mutationFailed message =>
    ({ model with loading := false, error := some message, status := "Mutation failed" },
      #[.toast .error message])

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
    let next := withSyncedEditor <| withNormalizedSelection { model with query := query }
    (setStatus next s!"Search: {query}", #[])

  | .statusFilterNext =>
    let next := withSyncedEditor <| withNormalizedSelection
      { model with statusFilter := model.statusFilter.next }
    (setStatus next s!"Status filter: {next.statusFilter.label}", #[])

  | .toggleBlockedOnly =>
    let next := withSyncedEditor <| withNormalizedSelection
      { model with blockedOnly := !model.blockedOnly }
    (setStatus next (if next.blockedOnly then "Blocked-only filter on" else "Blocked-only filter off"), #[])

  | .createTitleChanged title =>
    ({ model with createTitle := title }, #[])

  | .createDescriptionChanged description =>
    ({ model with createDescription := description }, #[])

  | .createAssigneeChanged assignee =>
    ({ model with createAssignee := assignee }, #[])

  | .createLabelsChanged labels =>
    ({ model with createLabels := labels }, #[])

  | .createPriorityNext =>
    ({ model with createPriority := nextPriority model.createPriority }, #[])

  | .createSubmitted =>
    if !canMutate model then
      (model, #[])
    else if !createTitleValid model then
      (setStatus { model with error := some "Create title is required" } "Create validation failed",
        #[.toast .error "Create title is required"])
    else
      let next := beginMutation model "Creating issue..."
      let labels := parseLabelsCsv model.createLabels
      let assignee := emptyAsNone model.createAssignee
      let effect := Effect.createIssue (Util.trim model.createTitle) model.createDescription
        model.createPriority labels assignee
      (next, #[effect])

  | .editTitleChanged title =>
    ({ model with editTitle := title }, #[])

  | .editDescriptionChanged description =>
    ({ model with editDescription := description }, #[])

  | .editAssigneeChanged assignee =>
    ({ model with editAssignee := assignee }, #[])

  | .editLabelsChanged labels =>
    ({ model with editLabels := labels }, #[])

  | .editPriorityNext =>
    ({ model with editPriority := nextPriority model.editPriority }, #[])

  | .editStatusNext =>
    ({ model with editStatus := nextStatus model.editStatus }, #[])

  | .saveEdits =>
    if !canMutate model then
      (model, #[])
    else
      match selectedIssueId? model with
      | none =>
        (setStatus { model with error := some "No selected issue" } "Save failed",
          #[.toast .error "No selected issue"])
      | some id =>
        let title := Util.trim model.editTitle
        if title.isEmpty then
          (setStatus { model with error := some "Issue title cannot be empty" } "Save validation failed",
            #[.toast .error "Issue title cannot be empty"])
        else
          let next := beginMutation model s!"Saving issue #{id}..."
          let labels := parseLabelsCsv model.editLabels
          let assignee := emptyAsNone model.editAssignee
          let effect := Effect.updateIssue id title model.editDescription model.editStatus
            model.editPriority labels assignee
          (next, #[effect])

  | .progressChanged message =>
    ({ model with progressMessage := message }, #[])

  | .addProgressSubmitted =>
    if !canMutate model then
      (model, #[])
    else
      match selectedIssueId? model with
      | none =>
        (setStatus { model with error := some "No selected issue" } "Progress failed",
          #[.toast .error "No selected issue"])
      | some id =>
        let message := Util.trim model.progressMessage
        if message.isEmpty then
          (setStatus { model with error := some "Progress message is required" } "Progress validation failed",
            #[.toast .error "Progress message is required"])
        else
          let next := beginMutation model s!"Adding progress to issue #{id}..."
          (next, #[.addProgress id message])

  | .closeCommentChanged comment =>
    ({ model with closeComment := comment }, #[])

  | .closeSubmitted =>
    if !canMutate model then
      (model, #[])
    else
      match selectedIssueId? model with
      | none =>
        (setStatus { model with error := some "No selected issue" } "Close failed",
          #[.toast .error "No selected issue"])
      | some id =>
        let next := beginMutation model s!"Closing issue #{id}..."
        let comment := emptyAsNone model.closeComment
        (next, #[.closeIssue id comment])

  | .reopenSubmitted =>
    if !canMutate model then
      (model, #[])
    else
      match selectedIssueId? model with
      | none =>
        (setStatus { model with error := some "No selected issue" } "Reopen failed",
          #[.toast .error "No selected issue"])
      | some id =>
        let next := beginMutation model s!"Reopening issue #{id}..."
        (next, #[.reopenIssue id])

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
