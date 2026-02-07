/-
  Tracker.GUI.App

  Reactive Tracker GUI shell wiring.
-/
import Reactive
import Afferent
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
    let keyEvents ← useKeyboard
    let keyActions ← Event.mapMaybeM
      (fun keyData => actionFromKey keyData.event.key)
      keyEvents
    let keyDispatch ← Event.mapM fireAction keyActions
    performEvent_ keyDispatch

    let _ ← dynWidget modelDyn fun model => do
      View.renderShell model fireAction

  events.registry.setupFocusClearing
  pure { render := render, shutdown := pure () }

/-- Launch Tracker GUI runtime with the reactive shell app. -/
def run : IO Unit :=
  Runtime.run createApp

end Tracker.GUI
