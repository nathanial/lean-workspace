/-
  Demo Runner - Canopy app linalg NoiseExplorer2D tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Linalg.NoiseExplorer2D
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos

def noiseExplorer2DTabContent (env : DemoEnv) : WidgetM Unit := do
  let initial := Demos.Linalg.noiseExplorer2DInitialState
  let (stateUpdates, fireStateUpdate) ← Reactive.newTriggerEvent
    (t := Spider) (a := Demos.Linalg.NoiseExplorerState → Demos.Linalg.NoiseExplorerState)

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
        emit (pure (Demos.Linalg.noiseExplorer2DWidget env s))
      pure ()

    column' (gap := 8.0 * env.screenScale) (style := panelStyle) do
      heading2' "Noise Explorer 2D"
      caption' "Perlin / Simplex / Value / Worley"
      spacer' 0 (6.0 * env.screenScale)

      caption' "Noise Type"
      let dropdownResult ← dropdown Demos.Linalg.noiseExplorerOptionLabels
        (Demos.Linalg.noiseExplorerOptionIndex initial.noiseType)
      let noiseTypeActions ← Event.mapM (fun idx =>
        let noiseType := Demos.Linalg.noiseExplorerOptionAt idx
        fireStateUpdate (fun s =>
          if s.noiseType == noiseType then s else { s with noiseType := noiseType }
        )
      ) dropdownResult.onSelect
      performEvent_ noiseTypeActions

      spacer' 0 (6.0 * env.screenScale)

      let switchResult ← switch (some "Use FBM") initial.useFbm
      let fbmActions ← Event.mapM (fun on =>
        fireStateUpdate (fun s =>
          if s.useFbm == on then s else { s with useFbm := on }
        )
      ) switchResult.onToggle
      performEvent_ fbmActions

      spacer' 0 (8.0 * env.screenScale)

      let wireSlider (which : Demos.Linalg.NoiseExplorerSlider) : WidgetM Unit := do
        let _ ← dynWidget state fun s =>
          caption' s!"{Demos.Linalg.noiseExplorerSliderLabel which}: {Demos.Linalg.noiseExplorerSliderValueLabel s which}"
        let sliderResult ← slider none (Demos.Linalg.noiseExplorerSliderT initial which)
        let sliderActions ← Event.mapM (fun t =>
          fireStateUpdate (fun s => Demos.Linalg.noiseExplorerApplySlider s which t)
        ) sliderResult.onChange
        performEvent_ sliderActions

      wireSlider .scale
      wireSlider .offsetX
      wireSlider .offsetY
      wireSlider .octaves
      wireSlider .lacunarity
      wireSlider .persistence
      wireSlider .jitter
      pure ()

  pure ()

end Demos
