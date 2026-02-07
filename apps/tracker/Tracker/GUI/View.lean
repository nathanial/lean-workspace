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

private def focusButton (label : String) (selected : Bool) : WidgetM (Event Spider Unit) :=
  button label (if selected then .primary else .ghost)

def renderShell (model : Tracker.GUI.Model) (fireAction : FireAction) : WidgetM Unit := do
  let rootStyle : Afferent.Arbor.BoxStyle := {
    backgroundColor := some (Color.gray 0.08)
    padding := Trellis.EdgeInsets.uniform 16
    width := .percent 1.0
    height := .percent 1.0
    flexItem := some (Trellis.FlexItem.growing 1)
  }

  column' (gap := 12) (style := rootStyle) do
    row' (gap := 12) (style := { width := .percent 1.0 }) do
      heading1' "Tracker"
      caption' "Reactive GUI shell (M1)"

    row' (gap := 8) (style := { width := .percent 1.0 }) do
      let issuesBtn ← focusButton "Issues" (model.focusPane == .issues)
      wireClick issuesBtn fireAction (.focusSet .issues)

      let detailBtn ← focusButton "Detail" (model.focusPane == .detail)
      wireClick detailBtn fireAction (.focusSet .detail)

      let actionsBtn ← focusButton "Actions" (model.focusPane == .actions)
      wireClick actionsBtn fireAction (.focusSet .actions)

      spacer' 16 0
      caption' s!"Focus: {model.focusPane.label}"

    let bodyStyle : Afferent.Arbor.BoxStyle := {
      flexItem := some (Trellis.FlexItem.growing 1)
      width := .percent 1.0
      height := .percent 1.0
    }

    row' (gap := 12) (style := bodyStyle) do
      let listStyle : Afferent.Arbor.BoxStyle := {
        flexItem := some (Trellis.FlexItem.fixed 320)
        width := .length 320
        height := .percent 1.0
      }
      column' (gap := 0) (style := listStyle) do
        outlinedPanel' 12 do
          heading3' "Issues"
          caption' "Arrow keys or j/k move selection"
          spacer' 0 8
          for idx in [:model.issueTitles.size] do
            let title := model.issueTitles[idx]!
            let selected := idx == model.selectedIssue
            let marker := if selected then ">" else " "
            let click ← button s!"{marker} {title}" (if selected then .primary else .ghost)
            wireClick click fireAction (.selectIssue idx)

      let detailStyle : Afferent.Arbor.BoxStyle := {
        flexItem := some (Trellis.FlexItem.growing 1)
        width := .percent 1.0
        height := .percent 1.0
      }
      column' (gap := 12) (style := detailStyle) do
        outlinedPanel' 12 do
          heading3' "Detail"
          caption' s!"Selected: {model.selectedTitle}"
          bodyText' "Issue detail editor and progress timeline will land in M2/M3."

        outlinedPanel' 12 do
          heading3' "Actions"
          caption' "Tab/Left/Right changes pane focus."
          caption' "Clicking controls fires FRP actions."

    outlinedPanel' 8 do
      caption' s!"Status: {model.status}"
      caption' "Keys: Tab focus | Left/Right focus | Up/Down select"

end Tracker.GUI.View
