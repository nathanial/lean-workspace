/-
  Demo Runner - Canopy app linalg DomainWarpingDemo tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Linalg.DomainWarpingDemo
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos
def domainWarpingDemoTabContent (env : DemoEnv) : WidgetM Unit := do
  let elapsedTime ← useElapsedTime
  let initial := Demos.Linalg.domainWarpingInitialState
  let (stateUpdates, fireStateUpdate) ← Reactive.newTriggerEvent
    (t := Spider) (a := Demos.Linalg.DomainWarpingState → Demos.Linalg.DomainWarpingState)

  -- Time-based animation updates (track lastTime in state)
  let timeUpdates ← Event.mapM (fun t =>
    fun (state : Demos.Linalg.DomainWarpingState) =>
      let dt := if state.lastTime == 0.0 then 0.0 else max 0.0 (t - state.lastTime)
      if state.animate then
        { state with time := state.time + dt * state.speed, lastTime := t }
      else
        { state with lastTime := t }
    ) elapsedTime.updated

  let allUpdates ← Event.mergeAllListM [stateUpdates, timeUpdates]
  let state ← foldDyn (fun f s => f s) initial allUpdates

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
        emit (pure (Demos.Linalg.domainWarpingDemoWidget env s))
      pure ()

    column' (gap := 8.0 * env.screenScale) (style := panelStyle) do
      heading2' "Domain Warping"
      caption' "warp2D / warp2DAdvanced"
      spacer' 0 (6.0 * env.screenScale)

      let wireSwitch (label : String)
          (getField : Demos.Linalg.DomainWarpingState → Bool)
          (setField : Demos.Linalg.DomainWarpingState → Bool → Demos.Linalg.DomainWarpingState)
          : WidgetM Unit := do
        let sw ← switch (some label) (getField initial)
        let actions ← Event.mapM (fun on =>
          fireStateUpdate (fun s =>
            let curr := getField s
            if curr == on then s else setField s on
          )
        ) sw.onToggle
        performEvent_ actions

      wireSwitch "Advanced" (fun s => s.useAdvanced)
        (fun s on => { s with useAdvanced := on })
      wireSwitch "Animate" (fun s => s.animate)
        (fun s on => { s with animate := on })
      wireSwitch "Show Vectors" (fun s => s.showVectors)
        (fun s on => { s with showVectors := on })

      spacer' 0 (8.0 * env.screenScale)

      let wireSlider (which : Demos.Linalg.WarpingSlider) : WidgetM Unit := do
        let _ ← dynWidget state fun s =>
          caption' s!"{Demos.Linalg.domainWarpingSliderLabel which}: {Demos.Linalg.domainWarpingSliderValueLabel s which}"
        let sliderResult ← slider none (Demos.Linalg.domainWarpingSliderT initial which)
        let sliderActions ← Event.mapM (fun t =>
          fireStateUpdate (fun s => Demos.Linalg.domainWarpingApplySlider s which t)
        ) sliderResult.onChange
        performEvent_ sliderActions

      for which in Demos.Linalg.domainWarpingSliderOrder do
        wireSlider which

      pure ()

  pure ()

end Demos
