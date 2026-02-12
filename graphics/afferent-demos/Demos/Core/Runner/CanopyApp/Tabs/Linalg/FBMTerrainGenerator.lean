/-
  Demo Runner - Canopy app linalg FBMTerrainGenerator tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Linalg.FBMTerrainGenerator
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Trellis

namespace Demos

def fbmTerrainGeneratorTabContent (env : DemoEnv) : WidgetM Unit := do
  let initial := Demos.Linalg.fbmTerrainInitialState
  let (stateUpdates, fireStateUpdate) ← Reactive.newTriggerEvent
    (t := Spider) (a := Demos.Linalg.FBMTerrainState → Demos.Linalg.FBMTerrainState)

  let plotName ← registerComponentW
  let plotClickEvents ← useClickData plotName
  let cameraStartUpdates ← Event.mapMaybeM (fun data =>
    if data.click.button == 1 then
      some (fun (s : Demos.Linalg.FBMTerrainState) =>
        { s with cameraDragging := true, lastMouseX := data.click.x, lastMouseY := data.click.y }
      )
    else
      none
    ) plotClickEvents

  let hoverEvents ← useAllHovers
  let cameraHoverUpdates ← Event.mapM (fun data =>
    fun (s : Demos.Linalg.FBMTerrainState) =>
      if s.cameraDragging then
        let dx := data.x - s.lastMouseX
        let dy := data.y - s.lastMouseY
        let newYaw := s.cameraYaw + dx * 0.005
        let newPitch := Linalg.Float.clamp (s.cameraPitch + dy * 0.005) (-0.2) 1.4
        { s with
          cameraYaw := newYaw
          cameraPitch := newPitch
          lastMouseX := data.x
          lastMouseY := data.y
        }
      else
        s
    ) hoverEvents

  let mouseUpEvents ← useAllMouseUp
  let cameraStopUpdates ← Event.mapMaybeM (fun data =>
    if data.button == 1 then
      some (fun (s : Demos.Linalg.FBMTerrainState) =>
        if s.cameraDragging then { s with cameraDragging := false } else s
      )
    else
      none
    ) mouseUpEvents

  let allUpdates ← Event.mergeAllListM
    [stateUpdates, cameraStartUpdates, cameraHoverUpdates, cameraStopUpdates]
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
        emit (namedColumn plotName 0 { width := .percent 1.0, height := .percent 1.0 } #[
          Demos.Linalg.fbmTerrainWidget env s
        ])
      pure ()

    column' (gap := 8.0 * env.screenScale) (style := panelStyle) do
      heading2' "FBM Terrain"
      caption' "fbm3D + redistribute + terrace"
      caption' "Right-drag in plot to rotate"
      spacer' 0 (6.0 * env.screenScale)

      let wireSwitch (label : String)
          (getField : Demos.Linalg.FBMTerrainState → Bool)
          (setField : Demos.Linalg.FBMTerrainState → Bool → Demos.Linalg.FBMTerrainState) : WidgetM Unit := do
        let sw ← switch (some label) (getField initial)
        let actions ← Event.mapM (fun on =>
          fireStateUpdate (fun s =>
            let curr := getField s
            if curr == on then s else setField s on
          )
        ) sw.onToggle
        performEvent_ actions

      wireSwitch "Wireframe" (fun s => s.showWireframe)
        (fun s on => { s with showWireframe := on })
      wireSwitch "Texture" (fun s => s.showTexture)
        (fun s on => { s with showTexture := on })
      wireSwitch "Normals" (fun s => s.showNormals)
        (fun s on => { s with showNormals := on })

      spacer' 0 (8.0 * env.screenScale)

      let wireSlider (which : Demos.Linalg.TerrainSlider) : WidgetM Unit := do
        let _ ← dynWidget state fun s =>
          caption' s!"{Demos.Linalg.fbmTerrainSliderLabel which}: {Demos.Linalg.fbmTerrainSliderValueLabel s which}"
        let sliderResult ← slider none (Demos.Linalg.fbmTerrainSliderT initial which)
        let sliderActions ← Event.mapM (fun t =>
          fireStateUpdate (fun s => Demos.Linalg.fbmTerrainApplySlider s which t)
        ) sliderResult.onChange
        performEvent_ sliderActions

      for which in Demos.Linalg.terrainSliderOrder do
        wireSlider which

      pure ()

  pure ()

end Demos
