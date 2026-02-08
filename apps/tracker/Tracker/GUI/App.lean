/-
  Tracker.GUI.App

  Reactive Tracker GUI shell wiring.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
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

private def toastSink (fireInfo fireSuccess fireError : String → IO Unit)
    : ToastSink :=
  fun level message =>
    match level with
    | .info => fireInfo message
    | .success => fireSuccess message
    | .error => fireError message

def createApp : ReactiveM GuiApp := do
  let events ← getEvents
  let (actionEvent, fireAction) ← Reactive.newTriggerEvent (t := Spider) (a := Action)
  let (effectEvent, fireEffects) ← Reactive.newTriggerEvent (t := Spider) (a := Array Effect)

  let (toastInfoEvent, fireToastInfo) ← Reactive.newTriggerEvent (t := Spider) (a := String)
  let (toastSuccessEvent, fireToastSuccess) ← Reactive.newTriggerEvent (t := Spider) (a := String)
  let (toastErrorEvent, fireToastError) ← Reactive.newTriggerEvent (t := Spider) (a := String)

  let toastDispatch := toastSink fireToastInfo fireToastSuccess fireToastError

  let modelDyn ← Reactive.foldDynM
    (fun action model => do
      let (nextModel, effects) := update model action
      SpiderM.liftIO <| fireEffects effects
      pure nextModel)
    Model.initial
    actionEvent
  let delayedEffects ← Reactive.Host.Event.delayFrameM effectEvent
  let effectActions ← Event.mapM (fun effects => runEffects fireAction toastDispatch effects) delayedEffects
  Reactive.Host.performEvent_ effectActions

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
        caption' "GUI M3: editable issue workflow"

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

      let toastMgr ← toastManager
      let infoAction ← Event.mapM (fun msg => toastMgr.showInfo msg) toastInfoEvent
      let successAction ← Event.mapM (fun msg => toastMgr.showSuccess msg) toastSuccessEvent
      let errorAction ← Event.mapM (fun msg => toastMgr.showError msg) toastErrorEvent
      performEvent_ infoAction
      performEvent_ successAction
      performEvent_ errorAction

  events.registry.setupFocusClearing
  SpiderM.liftIO <| fireAction .loadRequested
  pure { render := render, shutdown := pure () }

/-- Launch Tracker GUI runtime with the reactive shell app. -/
def run : IO Unit :=
  Runtime.run createApp

end Tracker.GUI
