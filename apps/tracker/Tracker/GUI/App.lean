/-
  Tracker.GUI.App

  Reactive Tracker GUI shell wiring.
-/
import Reactive
import Afferent
import Afferent.Canopy
import Afferent.Canopy.Reactive
import Tracker.GUI.Types
import Tracker.GUI.Model
import Tracker.GUI.Action
import Tracker.GUI.Update
import Tracker.GUI.Effect
import Tracker.GUI.View
import Tracker.GUI.Runtime

namespace Tracker.GUI

open Reactive Reactive.Host
open Afferent
open Afferent.Canopy
open Afferent.Canopy.Reactive

def createApp : ReactiveM GuiApp := do
  let events ← getEvents
  let (actionEvent, fireAction) ← Reactive.newTriggerEvent (t := Spider) (a := Action)

  let modelDyn ← Reactive.foldDynM
    (fun action model => do
      let (nextModel, effects) := update model action
      SpiderM.liftIO <| runEffects fireAction effects
      pure nextModel)
    Model.initial
    actionEvent

  let (_, render) ← runWidget do
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
        caption' "GUI M2: read-only issue browser"

      let search ← searchInput "Search issues..."
      let searchChangeAction ← Event.mapM (fun text => fireAction (.queryChanged text)) search.onChange
      performEvent_ searchChangeAction

      let focusedInput := events.registry.focusedInput
      let noInputFocused ← Dynamic.mapM Option.isNone focusedInput

      let keyEvents ← useKeyboard
      let globalKeys ← Event.gateM noInputFocused.current keyEvents
      let keyActions ← Event.mapMaybeM (fun keyData => actionFromKey keyData.event.key) globalKeys
      let keyDispatch ← Event.mapM fireAction keyActions
      performEvent_ keyDispatch

      let _ ← dynWidget modelDyn fun model =>
        View.renderModelSections model fireAction

  events.registry.setupFocusClearing
  SpiderM.liftIO <| fireAction .loadRequested
  pure { render := render, shutdown := pure () }

/-- Launch Tracker GUI runtime with the reactive shell app. -/
def run : IO Unit :=
  Runtime.run createApp

end Tracker.GUI
