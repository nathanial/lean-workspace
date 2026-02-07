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
    wireClick statusFilterBtn fireAction .statusFilterNext

    let blockedBtn ←
      button (if model.blockedOnly then "Blocked: on" else "Blocked: off")
        (if model.blockedOnly then .primary else .ghost)
    wireClick blockedBtn fireAction .toggleBlockedOnly

    let refreshBtn ← button "Refresh" .ghost
    wireClick refreshBtn fireAction .refresh

    spacer' 16 0
    caption' s!"Visible: {model.filteredCount} / Total: {model.totalCount}"

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
              wireClick click fireAction (.selectIssue issue.id)

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
        heading3' "Actions"
        caption' "Read-only mode (M2). Mutations arrive in M3."
        caption' "Keys: Tab focus | f status filter | b blocked-only | r refresh"

  outlinedPanel' 8 do
    caption' s!"Status: {model.status}"
    caption' s!"Root: {rootText model}"
    match model.error with
    | some error =>
      caption' s!"Error: {error}"
    | none =>
      caption' ""

end Tracker.GUI.View
