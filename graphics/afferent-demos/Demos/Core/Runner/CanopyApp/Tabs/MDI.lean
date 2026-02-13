/-
  Demo Runner - Canopy app MDI tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos

def mdiTabContent (_env : DemoEnv) : WidgetM Unit := do
  let rootStyle : BoxStyle := {
    width := .percent 1.0
    height := .percent 1.0
    flexItem := some (FlexItem.growing 1)
  }

  column' (gap := 8) (style := rootStyle) do
    caption' "MDI demo: drag titlebars, resize edges/corners, and snap to edges/corners/top."
    caption' "Try: overlap windows, then click overlap to verify topmost routing."

    let windows : Array MDIWindowSpec := #[
      {
        id := 1
        title := "Explorer"
        rect := { x := 28, y := 24, width := 320, height := 280 }
        content := do
          heading3' "Project"
          caption' "graphics/afferent"
          let _ ← checkbox "Show hidden files" false
          caption' "Drag this window by its titlebar."
      },
      {
        id := 2
        title := "Inspector"
        rect := { x := 390, y := 64, width := 360, height := 310 }
        content := do
          heading3' "Selection"
          caption' "Node: WindowRoot"
          let _ ← slider (some "Opacity") 0.7
          let _ ← slider (some "Scale") 1.0
          pure ()
      },
      {
        id := 3
        title := "Console"
        rect := { x := 170, y := 360, width := 520, height := 220 }
        content := do
          bodyText' "[build] compiling widget graph..."
          bodyText' "[input] hover stream active"
          bodyText' "[mdi] snap preview enabled"
          row' (gap := 8) (style := {}) do
            let _ ← button "Run" .primary
            let _ ← button "Clear" .outline
      },
      {
        id := 4
        title := "Preview"
        rect := { x := 780, y := 120, width := 280, height := 260 }
        content := do
          heading3' "Scene"
          caption' "Window content uses normal Canopy widgets."
          let _ ← toggleButton "Realtime"
          pure ()
      },
      {
        id := 5
        title := "Assets"
        rect := { x := 760, y := 420, width := 300, height := 220 }
        content := do
          heading3' "Recent"
          bodyText' "- orb.mesh"
          bodyText' "- terrain.png"
          bodyText' "- notes.txt"
      }
    ]

    let result ← mdi {
      fillWidth := true
      fillHeight := true
      minWindowWidth := 180
      minWindowHeight := 120
      titlebarHeight := 30
      snapThreshold := 30
      hostBackground := some (Color.gray 0.1)
    } windows

    let liftSpider {α : Type} : SpiderM α → WidgetM α := fun m => StateT.lift (liftM m)
    let moveLabelEv ← liftSpider <| Event.mapM (fun (windowId, rect) =>
      s!"Last move: w{windowId} -> ({rect.x}, {rect.y})") result.onWindowMove
    let resizeLabelEv ← liftSpider <| Event.mapM (fun (windowId, rect) =>
      s!"Last resize: w{windowId} -> {rect.width}x{rect.height}") result.onWindowResize
    let snapLabelEv ← liftSpider <| Event.mapM (fun (windowId, target) =>
      s!"Last snap: w{windowId} -> {repr target}") result.onWindowSnap
    let interactionLabelEv ← liftSpider <| Event.leftmostM [snapLabelEv, resizeLabelEv, moveLabelEv]
    let interactionLabelDyn ← liftSpider <| Reactive.holdDyn "Last interaction: none" interactionLabelEv

    let _ ← dynWidget result.activeWindow fun active => do
      let label :=
        match active with
        | some windowId => s!"Active window: {windowId}"
        | none => "Active window: none"
      caption' label

    let _ ← dynWidget interactionLabelDyn fun label => do
      caption' label

    pure ()

end Demos
