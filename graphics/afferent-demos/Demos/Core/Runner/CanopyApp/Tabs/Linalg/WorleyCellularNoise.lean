/-
  Demo Runner - Canopy app linalg WorleyCellularNoise tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Linalg.WorleyCellularNoise
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos
def worleyCellularNoiseTabContent (env : DemoEnv) : WidgetM Unit := do
  let initial := Demos.Linalg.worleyCellularInitialState
  let (stateUpdates, fireStateUpdate) ← Reactive.newTriggerEvent
    (t := Spider) (a := Demos.Linalg.WorleyCellularState → Demos.Linalg.WorleyCellularState)

  let state ← foldDyn (fun f s => f s) initial stateUpdates

  let panelWidth : Float := 300.0 * env.screenScale
  let rootStyle : BoxStyle := {
    flexItem := some (FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }
  let plotStyle : BoxStyle := {
    flexItem := some (FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }
  let panelStyle : BoxStyle := {
    flexItem := some (FlexItem.fixed panelWidth)
    width := .length panelWidth
    minWidth := some panelWidth
    height := .percent 1.0
    padding := EdgeInsets.uniform (16.0 * env.screenScale)
    backgroundColor := some (Color.rgba 0.08 0.08 0.1 0.95)
    borderColor := some (Color.gray 0.22)
    borderWidth := 1
  }

  row' (gap := 0) (style := rootStyle) do
    column' (gap := 0) (style := plotStyle) do
      let _ ← dynWidget state fun s => do
        emit (Demos.Linalg.worleyCellularNoiseWidget env s)
      pure ()

    column' (gap := 8.0 * env.screenScale) (style := panelStyle) do
      heading2' "Worley Cellular"
      caption' "worley2D + Voronoi"
      spacer' 0 (6.0 * env.screenScale)

      caption' "Mode"
      let dropdownResult ← dropdown Demos.Linalg.worleyModeOptionLabels
        (Demos.Linalg.worleyModeOptionIndex initial.mode)
      let modeActions ← Event.mapM (fun idx =>
        let mode := Demos.Linalg.worleyModeOptionAt idx
        fireStateUpdate (fun s =>
          if s.mode == mode then s else { s with mode := mode }
        )
      ) dropdownResult.onSelect
      performEvent_ modeActions

      spacer' 0 (6.0 * env.screenScale)

      let wireSwitch (label : String)
          (getField : Demos.Linalg.WorleyCellularState → Bool)
          (setField : Demos.Linalg.WorleyCellularState → Bool → Demos.Linalg.WorleyCellularState)
          : WidgetM Unit := do
        let sw ← switch (some label) (getField initial)
        let actions ← Event.mapM (fun on =>
          fireStateUpdate (fun s =>
            let curr := getField s
            if curr == on then s else setField s on
          )
        ) sw.onToggle
        performEvent_ actions

      wireSwitch "Show Edges" (fun s => s.showEdges)
        (fun s on => { s with showEdges := on })
      wireSwitch "Show Points" (fun s => s.showPoints)
        (fun s on => { s with showPoints := on })
      wireSwitch "Connections" (fun s => s.showConnections)
        (fun s on => { s with showConnections := on })

      spacer' 0 (8.0 * env.screenScale)

      let _ ← dynWidget state fun s =>
        caption' s!"Jitter: {Demos.Linalg.worleyJitterLabel s}"
      let sliderResult ← slider none (Demos.Linalg.worleyJitterSliderT initial)
      let jitterActions ← Event.mapM (fun t =>
        fireStateUpdate (fun s => Demos.Linalg.worleyApplyJitterSlider s t)
      ) sliderResult.onChange
      performEvent_ jitterActions

      pure ()

  pure ()

end Demos
