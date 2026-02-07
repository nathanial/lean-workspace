import Afferent
import Afferent.Canopy
import Afferent.Canopy.Reactive
import Tracker.GUI.Action
import Tracker.GUI.Model

namespace Tracker.GUI.View

open Reactive Reactive.Host
open Afferent
open Afferent.Canopy
open Afferent.Canopy.Reactive

abbrev FireAction := Tracker.GUI.Action → IO Unit

private def wireClick (click : Event Spider Unit) (fireAction : FireAction)
    (action : Tracker.GUI.Action) : WidgetM Unit := do
  let actionEvent ← Event.mapM (fun _ => fireAction action) click
  performEvent_ actionEvent

private def wireClickIf (enabled : Bool) (click : Event Spider Unit)
    (fireAction : FireAction) (action : Tracker.GUI.Action) : WidgetM Unit := do
  if enabled then
    wireClick click fireAction action
  else
    pure ()

private def bindTextInput (placeholder initial : String) (fireAction : FireAction)
    (mkAction : String → Tracker.GUI.Action) : WidgetM Unit := do
  let input ← textInput placeholder initial
  let onChange ← Event.mapM (fun text => fireAction (mkAction text)) input.onChange
  performEvent_ onChange

private def bindTextArea (placeholder initial : String) (width : Float) (height : Float)
    (fireAction : FireAction) (mkAction : String → Tracker.GUI.Action) : WidgetM Unit := do
  let initState : TextAreaState := { value := initial, cursor := initial.length }
  let area ← textArea placeholder initState width height
  let onChange ← Event.mapM (fun text => fireAction (mkAction text)) area.onChange
  performEvent_ onChange

private def labelsText (labels : Array String) : String :=
  if labels.isEmpty then "-"
  else String.intercalate ", " labels.toList

private def natListText (values : Array Nat) : String :=
  if values.isEmpty then "-"
  else String.intercalate ", " (values.map toString).toList

private def rootText (model : Tracker.GUI.Model) : String :=
  match model.root with
  | some root => root.toString
  | none => "(not loaded)"

private def issueRowLabel (issue : Issue) : String :=
  let blocked := if issue.isBlocked then " [blocked]" else ""
  s!"#{issue.id} [{issue.status.toString}] [{issue.priority.toString}] {issue.title}{blocked}"

def renderModelSections (model : Tracker.GUI.Model) (fireAction : FireAction) : WidgetM Unit := do
  row' (gap := 8) (style := { width := .percent 1.0 }) do
    let statusFilterBtn ← button s!"Status: {model.statusFilter.label}" .secondary
    wireClickIf (!model.loading) statusFilterBtn fireAction .statusFilterNext

    let blockedBtn ←
      button (if model.blockedOnly then "Blocked: on" else "Blocked: off")
        (if model.blockedOnly then .primary else .ghost)
    wireClickIf (!model.loading) blockedBtn fireAction .toggleBlockedOnly

    let refreshBtn ← button "Refresh" .ghost
    wireClickIf (!model.loading) refreshBtn fireAction .refresh

    spacer' 16 0
    caption' s!"Visible: {model.filteredCount} / Total: {model.totalCount}"
    if model.loading then
      caption' "Working..."
    else
      spacer' 0 0

  let bodyStyle : Afferent.Arbor.BoxStyle := {
    flexItem := some (Trellis.FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }

  row' (gap := 12) (style := bodyStyle) do
    let listStyle : Afferent.Arbor.BoxStyle := {
      flexItem := some (Trellis.FlexItem.fixed 420)
      width := .length 420
      height := .percent 1.0
    }

    column' (gap := 0) (style := listStyle) do
      outlinedPanel' 12 do
        heading3' "Issues"
        caption' "Arrow keys or j/k move selection"
        spacer' 0 8
        if model.loading then
          bodyText' "Loading issues..."
        else
          let visible := model.filteredIssues
          if visible.isEmpty then
            bodyText' "No issues match the current filter/search."
          else
            for issue in visible do
              let selected := model.selectedIssueId == some issue.id
              let click ← button (issueRowLabel issue) (if selected then .primary else .ghost)
              wireClickIf (!model.loading) click fireAction (.selectIssue issue.id)

    let detailStyle : Afferent.Arbor.BoxStyle := {
      flexItem := some (Trellis.FlexItem.growing 1)
      width := .percent 1.0
      height := .percent 1.0
    }

    column' (gap := 12) (style := detailStyle) do
      outlinedPanel' 12 do
        heading3' "Detail"
        if model.loading then
          bodyText' "Loading issue details..."
        else
          match model.selectedIssue? with
          | none =>
            bodyText' "No issue selected."
          | some issue =>
            bodyText' s!"#{issue.id} {issue.title}"
            caption' s!"Status: {issue.status.toString}"
            caption' s!"Priority: {issue.priority.toString}"
            caption' s!"Created: {issue.created}"
            caption' s!"Updated: {issue.updated}"
            caption' s!"Assignee: {issue.assignee.getD "-"}"
            caption' s!"Project: {issue.project.getD "-"}"
            caption' s!"Labels: {labelsText issue.labels}"
            caption' s!"Blocked by: {natListText issue.blockedBy}"
            caption' s!"Blocks: {natListText issue.blocks}"
            spacer' 0 6
            heading3' "Description"
            bodyText' (if issue.description.isEmpty then "(no description)" else issue.description)
            spacer' 0 6
            heading3' s!"Progress ({issue.progress.size})"
            if issue.progress.isEmpty then
              caption' "No progress entries."
            else
              let recent := issue.progress.reverse |>.take 5
              for entry in recent do
                caption' s!"- {entry.timestamp}: {entry.message}"

      outlinedPanel' 12 do
        heading3' "Edit Metadata"
        caption' "Edit selected issue then save"
        bindTextInput "Title" model.editTitle fireAction .editTitleChanged
        bindTextInput "Assignee (optional)" model.editAssignee fireAction .editAssigneeChanged
        bindTextInput "Labels (comma-separated)" model.editLabels fireAction .editLabelsChanged
        bindTextArea "Description" model.editDescription 560 110 fireAction .editDescriptionChanged

        row' (gap := 8) (style := { width := .percent 1.0 }) do
          let statusBtn ← button s!"Status: {model.editStatus.toString}" .secondary
          wireClickIf (!model.loading) statusBtn fireAction .editStatusNext

          let priorityBtn ← button s!"Priority: {model.editPriority.toString}" .secondary
          wireClickIf (!model.loading) priorityBtn fireAction .editPriorityNext

          let saveBtn ← button "Save Metadata" .success
          wireClickIf (!model.loading) saveBtn fireAction .saveEdits

      outlinedPanel' 12 do
        heading3' "Progress"
        bindTextInput "Add progress note" model.progressMessage fireAction .progressChanged
        let addBtn ← button "Add Progress" .primary
        wireClickIf (!model.loading) addBtn fireAction .addProgressSubmitted

      outlinedPanel' 12 do
        heading3' "Lifecycle"
        bindTextInput "Close comment (optional)" model.closeComment fireAction .closeCommentChanged
        match model.selectedIssue? with
        | some issue =>
          if issue.status == .closed then
            let reopenBtn ← button "Reopen Issue" .success
            wireClickIf (!model.loading) reopenBtn fireAction .reopenSubmitted
          else
            let closeBtn ← button "Close Issue" .danger
            wireClickIf (!model.loading) closeBtn fireAction .closeSubmitted
        | none =>
          caption' "Select an issue first."

      outlinedPanel' 12 do
        heading3' "Create Issue"
        bindTextInput "Title" model.createTitle fireAction .createTitleChanged
        bindTextInput "Assignee (optional)" model.createAssignee fireAction .createAssigneeChanged
        bindTextInput "Labels (comma-separated)" model.createLabels fireAction .createLabelsChanged
        bindTextArea "Description" model.createDescription 560 110 fireAction .createDescriptionChanged

        row' (gap := 8) (style := { width := .percent 1.0 }) do
          let priorityBtn ← button s!"Priority: {model.createPriority.toString}" .secondary
          wireClickIf (!model.loading) priorityBtn fireAction .createPriorityNext

          let createBtn ← button "Create Issue" .success
          wireClickIf (!model.loading) createBtn fireAction .createSubmitted

  outlinedPanel' 8 do
    caption' s!"Status: {model.status}"
    caption' s!"Root: {rootText model}"
    match model.error with
    | some error =>
      caption' s!"Error: {error}"
    | none =>
      caption' ""

end Tracker.GUI.View
