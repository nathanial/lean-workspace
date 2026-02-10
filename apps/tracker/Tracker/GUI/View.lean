import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
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

private def issueRowVisual (theme : Theme) (text : String) (selected : Bool)
    (width itemHeight : Float) : Afferent.Arbor.WidgetBuilder := do
  let bgColor :=
    if selected then theme.primary.background.withAlpha 0.2
    else Color.transparent
  let fgColor :=
    if selected then theme.primary.foreground
    else theme.text
  let rowStyle : Afferent.Arbor.BoxStyle := {
    backgroundColor := some bgColor
    padding := Trellis.EdgeInsets.symmetric 8 6
    width := .percent 1.0
    minHeight := some itemHeight
  }
  let wid ← Afferent.Arbor.freshId
  let props : Trellis.FlexContainer := {
    Trellis.FlexContainer.row 0 with
    alignItems := .center
  }
  let label ← bodyText text theme fgColor .left (some (width - 12))
  pure (.flex wid none props rowStyle #[label])

private structure ListPaneModel where
  loading : Bool
  statusFilter : StatusFilter
  blockedOnly : Bool
  filteredCount : Nat
  totalCount : Nat
  visible : Array Issue
  selectedIssueId : Option Nat
  deriving Repr, BEq, Inhabited

private def toListPaneModel (model : Tracker.GUI.Model) : ListPaneModel :=
  {
    loading := model.loading
    statusFilter := model.statusFilter
    blockedOnly := model.blockedOnly
    filteredCount := model.filteredCount
    totalCount := model.totalCount
    visible := model.filteredIssues
    selectedIssueId := model.selectedIssueId
  }

private def renderControls (model : ListPaneModel) (fireAction : FireAction) : WidgetM Unit := do
  row' (gap := 8) (style := { width := .percent 1.0 }) do
    let statusFilterBtn ← button s!"Status: {model.statusFilter.label}" .secondary
    wireClickIf (!model.loading) statusFilterBtn fireAction .statusFilterNext

    if model.loading then
      let theme ← getThemeW
      let blockedSwitchName ←
        registerComponentW "tracker-blocked-switch" (isInteractive := false)
      emit (pure (switchVisual blockedSwitchName (some "Blocked only") theme model.blockedOnly))
    else
      let blockedSwitch ← switch (some "Blocked only") model.blockedOnly
      let blockedSwitchAction ←
        Event.mapM (fun _ => fireAction .toggleBlockedOnly) blockedSwitch.onToggle
      performEvent_ blockedSwitchAction

    let refreshBtn ← button "Refresh" .ghost
    wireClickIf (!model.loading) refreshBtn fireAction .refresh

    spacer' 16 0
    caption' s!"Visible: {model.filteredCount} / Total: {model.totalCount}"
    if model.loading then
      caption' "Working..."
    else
      spacer' 0 0

private def renderIssueListPane (model : ListPaneModel) (fireAction : FireAction) : WidgetM Unit := do
  let listStyle : Afferent.Arbor.BoxStyle := {
    flexItem := some (Trellis.FlexItem.fixed 420)
    width := .length 420
    height := .percent 1.0
  }
  column' (gap := 0) (style := listStyle) do
    outlinedPanel' 12 do
      heading3' "Issues"
      spacer' 0 8
      if model.loading then
        bodyText' "Loading issues..."
      else
        if model.visible.isEmpty then
          bodyText' "No issues match the current filter/search."
        else
          let listWidth : Float := 396
          let listHeight : Float := 1200
          let itemHeight : Float := 34
          let theme ← getThemeW
          let listConfig : VirtualListConfig := {
            width := listWidth
            height := listHeight
            fillWidth := true
            fillHeight := true
            instanceKey := some "tracker-issues"
            itemHeight := itemHeight
            overscan := 4
          }
          let listResult ← virtualList model.visible.size (fun idx => do
            match model.visible[idx]? with
            | none =>
              Afferent.Arbor.spacer listWidth itemHeight
            | some issue =>
              let selected := model.selectedIssueId == some issue.id
              issueRowVisual theme (issueRowLabel issue) selected listWidth itemHeight
          ) listConfig
          let selectAction ← Event.mapM (fun idx => do
            match model.visible[idx]? with
            | some issue =>
              fireAction (.selectIssue issue.id)
            | none =>
              pure ()
          ) listResult.onItemClick
          performEvent_ selectAction

private def renderDetailPane (model : Tracker.GUI.Model) (fireAction : FireAction) : WidgetM Unit := do
  let detailStyle : Afferent.Arbor.BoxStyle := {
    flexItem := some (Trellis.FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }
  column' (gap := 12) (style := detailStyle) do
    let rightPaneScrollConfig : ScrollContainerConfig := {
      width := 860
      height := 1200
      verticalScroll := true
      horizontalScroll := false
      fillWidth := true
      fillHeight := true
      scrollbarVisibility := .always
    }
    let _ ← scrollContainer rightPaneScrollConfig do
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
            let theme ← getThemeW
            let description := if issue.description.isEmpty then "(no description)" else issue.description
            emit (pure (bodyText description theme (maxWidth := some 760)))
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
      pure ()

private def renderStatusPanel (model : Tracker.GUI.Model) : WidgetM Unit := do
  outlinedPanel' 8 do
    caption' s!"Status: {model.status}"
    caption' s!"Root: {rootText model}"
    match model.error with
    | some error =>
      caption' s!"Error: {error}"
    | none =>
      caption' ""

def renderModelSections (modelDyn : Dynamic Spider Tracker.GUI.Model) (fireAction : FireAction)
    : WidgetM Unit := do
  let listModelDynRaw ← Dynamic.mapM toListPaneModel modelDyn
  let listModelDyn ← Dynamic.holdUniqDynM listModelDynRaw

  let _ ← dynWidget listModelDyn fun model =>
    renderControls model fireAction

  let bodyStyle : Afferent.Arbor.BoxStyle := {
    flexItem := some (Trellis.FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }

  row' (gap := 12) (style := bodyStyle) do
    let _ ← dynWidget listModelDyn fun model =>
      renderIssueListPane model fireAction
    let _ ← dynWidget modelDyn fun model =>
      renderDetailPane model fireAction

  let _ ← dynWidget modelDyn fun model =>
    renderStatusPanel model

end Tracker.GUI.View
