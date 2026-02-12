/-
  Demo Runner - Canopy app visuals VoxelWorld tab content.
-/
import Reactive
import Afferent
import Afferent.UI.Canopy
import Afferent.UI.Canopy.Reactive
import Demos.Core.Demo
import Demos.Visuals.VoxelWorld
import Trellis

open Reactive Reactive.Host
open Afferent
open Afferent.Arbor
open Afferent.Canopy
open Afferent.Canopy.Reactive
open Afferent.Render
open Trellis

namespace Demos

structure VoxelWorldInputState where
  w : Bool := false
  a : Bool := false
  s : Bool := false
  d : Bool := false
  q : Bool := false
  e : Bool := false
  deriving Inhabited

structure VoxelWorldTabState where
  params : Demos.VoxelWorldParams := {}
  mesh : Afferent.Widget.VoxelMesh := Demos.buildVoxelWorldMesh {}
  camera : FPSCamera := Demos.voxelWorldInitialCamera
  locked : Bool := false
  keys : VoxelWorldInputState := {}
  delta : MouseDeltaData := { dx := 0.0, dy := 0.0 }
  lastTime : Float := 0.0
  deriving Inhabited

private def updateParams (rebuildMesh : Bool)
    (f : Demos.VoxelWorldParams → Demos.VoxelWorldParams)
    (state : VoxelWorldTabState) : VoxelWorldTabState :=
  let params' := f state.params
  if params' == state.params then
    state
  else if rebuildMesh then
    { state with params := params', mesh := Demos.buildVoxelWorldMesh params' }
  else
    { state with params := params' }

def voxelWorldTabContent (env : DemoEnv) : WidgetM Unit := do
  let initial : VoxelWorldTabState := {}
  let elapsedTime ← useElapsedTime
  let sceneName ← registerComponentW
  let clickEvents ← useClick sceneName
  let keyEvents ← useKeyboardAll
  let mouseDeltas ← useMouseDelta

  let (stateUpdates, fireStateUpdate) ← Reactive.newTriggerEvent
    (t := Spider) (a := VoxelWorldTabState → VoxelWorldTabState)

  let clickUpdates ← Event.mapM (fun _ =>
    fun (s : VoxelWorldTabState) =>
      if s.locked then s else { s with locked := true }
    ) clickEvents

  let keyUpdates ← Event.mapM (fun data =>
    let key := data.event.key
    let isPress := data.event.isPress
    fun (s : VoxelWorldTabState) =>
      let locked := if key == .escape && isPress then !s.locked else s.locked
      let keys := match key with
        | .char 'w' => { s.keys with w := isPress }
        | .char 'a' => { s.keys with a := isPress }
        | .char 's' => { s.keys with s := isPress }
        | .char 'd' => { s.keys with d := isPress }
        | .char 'q' => { s.keys with q := isPress }
        | .char 'e' => { s.keys with e := isPress }
        | _ => s.keys
      { s with locked := locked, keys := keys }
    ) keyEvents

  let deltaUpdates ← Event.mapM (fun delta =>
    fun (s : VoxelWorldTabState) => { s with delta := delta }
    ) mouseDeltas

  let timeUpdates ← Event.mapM (fun t =>
    fun (s : VoxelWorldTabState) =>
      let dt := if s.lastTime == 0.0 then 0.0 else max 0.0 (t - s.lastTime)
      let dx := if s.locked then s.delta.dx else 0.0
      let dy := if s.locked then s.delta.dy else 0.0
      let camera := s.camera.update dt s.keys.w s.keys.s s.keys.a s.keys.d s.keys.e s.keys.q dx dy
      { s with camera := camera, lastTime := t }
    ) elapsedTime.updated

  let allUpdates ← Event.mergeAllListM
    [stateUpdates, clickUpdates, keyUpdates, deltaUpdates, timeUpdates]
  let state ← foldDyn (fun f s => f s) initial allUpdates

  let rootStyle : BoxStyle := {
    flexItem := some (FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }
  let sceneStyle : BoxStyle := {
    flexItem := some (FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
  }
  let panelWidth : Float := 320.0 * env.screenScale
  let panelStyle : BoxStyle := {
    flexItem := some (FlexItem.fixed panelWidth)
    width := .length panelWidth
    minWidth := some panelWidth
    height := .percent 1.0
    padding := EdgeInsets.uniform (16.0 * env.screenScale)
    backgroundColor := some (Color.rgba 0.08 0.08 0.1 0.95)
    borderColor := some (Color.gray 0.24)
    borderWidth := 1
  }

  row' (gap := 0) (style := rootStyle) do
    column' (gap := 0) (style := sceneStyle) do
      let _ ← dynWidget state fun s => do
        SpiderM.liftIO (FFI.Window.setPointerLock env.window s.locked)
        emit (Demos.voxelWorldWidget sceneName s.mesh s.camera s.params)
      pure ()

    column' (gap := 8.0 * env.screenScale) (style := panelStyle) do
      heading2' "Voxel World"
      caption' "Click viewport to lock pointer, Esc to release."
      caption' "WASDQE move, mouse look."
      spacer' 0 (4.0 * env.screenScale)

      let _ ← dynWidget state fun s =>
        caption' s!"Palette: {Demos.voxelWorldPaletteLabel s.params.palette}"
      let paletteButton ← button "Cycle Palette" .secondary
      let paletteActions ← Event.mapM (fun _ =>
        fireStateUpdate (updateParams true (fun p =>
          { p with palette := Demos.voxelWorldNextPalette p.palette }))
      ) paletteButton
      performEvent_ paletteActions

      let fogSwitch ← switch (some "Fog") initial.params.fogEnabled
      let fogActions ← Event.mapM (fun on =>
        fireStateUpdate (updateParams false (fun p => { p with fogEnabled := on }))
      ) fogSwitch.onToggle
      performEvent_ fogActions

      let chunkBoundarySwitch ← switch (some "Chunk Boundaries") initial.params.showChunkBoundaries
      let chunkBoundaryActions ← Event.mapM (fun on =>
        fireStateUpdate (updateParams true (fun p => { p with showChunkBoundaries := on }))
      ) chunkBoundarySwitch.onToggle
      performEvent_ chunkBoundaryActions

      spacer' 0 (6.0 * env.screenScale)

      let _ ← dynWidget state fun s =>
        caption' s!"Chunk radius: {s.params.chunkRadius}"
      let radiusSlider ← slider none (Demos.voxelWorldRadiusToSlider initial.params.chunkRadius)
      let radiusActions ← Event.mapM (fun t =>
        fireStateUpdate (updateParams true (fun p =>
          { p with chunkRadius := Demos.voxelWorldRadiusFromSlider t }))
      ) radiusSlider.onChange
      performEvent_ radiusActions

      let _ ← dynWidget state fun s =>
        caption' s!"Chunk height: {s.params.chunkHeight}"
      let heightSlider ← slider none (Demos.voxelWorldHeightToSlider initial.params.chunkHeight)
      let heightActions ← Event.mapM (fun t =>
        fireStateUpdate (updateParams true (fun p =>
          { p with chunkHeight := Demos.voxelWorldHeightFromSlider t }))
      ) heightSlider.onChange
      performEvent_ heightActions

      let _ ← dynWidget state fun s =>
        caption' s!"Base height: {s.params.baseHeight}"
      let baseHeightSlider ← slider none (Demos.voxelWorldBaseHeightToSlider initial.params.baseHeight)
      let baseHeightActions ← Event.mapM (fun t =>
        fireStateUpdate (updateParams true (fun p =>
          { p with baseHeight := Demos.voxelWorldBaseHeightFromSlider t }))
      ) baseHeightSlider.onChange
      performEvent_ baseHeightActions

      let _ ← dynWidget state fun s =>
        caption' s!"Height range: {s.params.heightRange}"
      let rangeSlider ← slider none (Demos.voxelWorldRangeToSlider initial.params.heightRange)
      let rangeActions ← Event.mapM (fun t =>
        fireStateUpdate (updateParams true (fun p =>
          { p with heightRange := Demos.voxelWorldRangeFromSlider t }))
      ) rangeSlider.onChange
      performEvent_ rangeActions

      let _ ← dynWidget state fun s =>
        caption' s!"Frequency: {s.params.frequency}"
      let frequencySlider ← slider none (Demos.voxelWorldFrequencyToSlider initial.params.frequency)
      let frequencyActions ← Event.mapM (fun t =>
        fireStateUpdate (updateParams true (fun p =>
          { p with frequency := Demos.voxelWorldFrequencyFromSlider t }))
      ) frequencySlider.onChange
      performEvent_ frequencyActions

      let _ ← dynWidget state fun s =>
        caption' s!"Terrace step: {s.params.terraceStep}"
      let terraceSlider ← slider none (Demos.voxelWorldTerraceToSlider initial.params.terraceStep)
      let terraceActions ← Event.mapM (fun t =>
        fireStateUpdate (updateParams true (fun p =>
          { p with terraceStep := Demos.voxelWorldTerraceFromSlider t }))
      ) terraceSlider.onChange
      performEvent_ terraceActions

      spacer' 0 (8.0 * env.screenScale)
      let _ ← dynWidget state fun s =>
        caption' s!"Vertices: {s.mesh.vertices.size / 10}  Triangles: {s.mesh.indices.size / 3}"
      pure ()

  pure ()

end Demos
