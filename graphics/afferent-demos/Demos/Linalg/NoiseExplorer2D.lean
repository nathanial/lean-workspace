/-
  Noise Explorer 2D - Visualize Perlin, Simplex, Value, and Worley noise.
  Includes FBM controls, scale, and offset sliders.
-/
import Afferent
import Afferent.UI.Widget
import Afferent.UI.Arbor
import Demos.Core.Demo
import Demos.Linalg.Shared
import Trellis
import Linalg.Core
import Linalg.Vec2
import Linalg.Noise
import AfferentMath.Widget.MathView2D

open Afferent CanvasM Linalg
open Afferent.Widget
open AfferentMath.Widget

namespace Demos.Linalg

inductive NoiseType where
  | perlin
  | simplex
  | value
  | worley
  deriving BEq, Inhabited

def NoiseType.label : NoiseType -> String
  | .perlin => "Perlin"
  | .simplex => "Simplex"
  | .value => "Value"
  | .worley => "Worley"

inductive NoiseExplorerSlider where
  | scale
  | offsetX
  | offsetY
  | octaves
  | lacunarity
  | persistence
  | jitter
  deriving BEq, Inhabited

inductive NoiseExplorerDrag where
  | none
  | slider (which : NoiseExplorerSlider)
  deriving BEq, Inhabited

structure NoiseExplorerState where
  noiseType : NoiseType := .perlin
  useFbm : Bool := true
  scale : Float := 2.4
  offset : Vec2 := Vec2.zero
  config : Noise.FractalConfig := {}
  jitter : Float := 1.0
  dropdownOpen : Bool := false
  dragging : NoiseExplorerDrag := .none
  deriving Inhabited

def noiseExplorer2DInitialState : NoiseExplorerState := {}

private structure NoiseExplorerCacheKey where
  noiseType : NoiseType
  useFbm : Bool
  scale : Float
  offsetX : Float
  offsetY : Float
  octaves : Nat
  lacunarity : Float
  persistence : Float
  jitter : Float
  res : Nat
  deriving BEq, Inhabited

private structure NoiseExplorerCache where
  key : Option NoiseExplorerCacheKey := none
  samples : Array Float := #[]
  deriving Inhabited

initialize noiseExplorerCacheRef : IO.Ref NoiseExplorerCache ← IO.mkRef {}

private structure NoiseExplorerRectBatchKey where
  sampleKey : NoiseExplorerCacheKey
  plotW : Float
  plotH : Float
  originX : Float
  originY : Float
  deriving BEq, Inhabited

private structure NoiseExplorerRectBatchCache where
  key : Option NoiseExplorerRectBatchKey := none
  data : Array Float := #[]
  count : Nat := 0
  deriving Inhabited

initialize noiseExplorerRectBatchCacheRef : IO.Ref NoiseExplorerRectBatchCache ← IO.mkRef {}

def noiseExplorerMathViewConfig (screenScale : Float) : MathView2D.Config := {
  style := { flexItem := some (Trellis.FlexItem.growing 1) }
  scale := 80.0 * screenScale
  showGrid := false
  showAxes := false
  showLabels := false
}

structure NoiseExplorerSliderLayout where
  x : Float
  y : Float
  width : Float
  height : Float

structure NoiseExplorerToggleLayout where
  x : Float
  y : Float
  size : Float

structure NoiseExplorerDropdownLayout where
  x : Float
  y : Float
  width : Float
  height : Float

def noiseExplorerOptions : Array NoiseType := #[.perlin, .simplex, .value, .worley]

private def panelWidth (screenScale : Float) : Float :=
  270.0 * screenScale

private def panelX (w screenScale : Float) : Float :=
  w - panelWidth screenScale

def noiseExplorerDropdownLayout (w _h screenScale : Float) : NoiseExplorerDropdownLayout :=
  let x := panelX w screenScale + 20.0 * screenScale
  let y := 90.0 * screenScale
  let width := panelWidth screenScale - 40.0 * screenScale
  let height := 28.0 * screenScale
  { x := x, y := y, width := width, height := height }

def noiseExplorerDropdownOptionLayout (base : NoiseExplorerDropdownLayout) (idx : Nat)
    : NoiseExplorerDropdownLayout :=
  { x := base.x, y := base.y + base.height + idx.toFloat * base.height,
    width := base.width, height := base.height }

def noiseExplorerFbmToggleLayout (w _h screenScale : Float) : NoiseExplorerToggleLayout :=
  let x := panelX w screenScale + 20.0 * screenScale
  let y := 130.0 * screenScale
  let size := 16.0 * screenScale
  { x := x, y := y, size := size }

def noiseExplorerSliderLayout (w _h screenScale : Float) (idx : Nat) : NoiseExplorerSliderLayout :=
  let startX := panelX w screenScale + 20.0 * screenScale
  let startY := 170.0 * screenScale
  let width := panelWidth screenScale - 40.0 * screenScale
  let height := 8.0 * screenScale
  let spacing := 34.0 * screenScale
  { x := startX, y := startY + idx.toFloat * spacing, width := width, height := height }

private def clamp01 (t : Float) : Float :=
  Float.clamp t 0.0 1.0

private def scaleFromSlider (t : Float) : Float :=
  0.4 + 6.6 * t

private def scaleToSlider (v : Float) : Float :=
  clamp01 ((v - 0.4) / 6.6)

private def offsetFromSlider (t : Float) : Float :=
  -4.0 + 8.0 * t

private def offsetToSlider (v : Float) : Float :=
  clamp01 ((v + 4.0) / 8.0)

private def lacunarityFromSlider (t : Float) : Float :=
  1.5 + 2.2 * t

private def lacunarityToSlider (v : Float) : Float :=
  clamp01 ((v - 1.5) / 2.2)

private def persistenceFromSlider (t : Float) : Float :=
  0.25 + 0.65 * t

private def persistenceToSlider (v : Float) : Float :=
  clamp01 ((v - 0.25) / 0.65)

private def octavesFromSlider (t : Float) : Nat :=
  let v := Float.floor (1.0 + t * 7.0)
  let n := v.toUInt64.toNat
  if n < 1 then 1 else if n > 8 then 8 else n

private def octavesToSlider (n : Nat) : Float :=
  clamp01 ((n.toFloat - 1.0) / 7.0)

private def jitterFromSlider (t : Float) : Float :=
  clamp01 t

private def jitterToSlider (v : Float) : Float :=
  clamp01 v

private def floorToNat (x : Float) : Nat :=
  (Float.floor x).toUInt64.toNat

private def sliderLabel (which : NoiseExplorerSlider) : String :=
  match which with
  | .scale => "Scale"
  | .offsetX => "Offset X"
  | .offsetY => "Offset Y"
  | .octaves => "Octaves"
  | .lacunarity => "Lacunarity"
  | .persistence => "Persistence"
  | .jitter => "Jitter"

private def sliderValueLabel (state : NoiseExplorerState) (which : NoiseExplorerSlider) : String :=
  match which with
  | .scale => formatFloat state.scale
  | .offsetX => formatFloat state.offset.x
  | .offsetY => formatFloat state.offset.y
  | .octaves => s!"{state.config.octaves}"
  | .lacunarity => formatFloat state.config.lacunarity
  | .persistence => formatFloat state.config.persistence
  | .jitter => formatFloat state.jitter

def noiseExplorerApplySlider (state : NoiseExplorerState) (which : NoiseExplorerSlider) (t : Float)
    : NoiseExplorerState :=
  let t := clamp01 t
  match which with
  | .scale => { state with scale := scaleFromSlider t }
  | .offsetX => { state with offset := Vec2.mk (offsetFromSlider t) state.offset.y }
  | .offsetY => { state with offset := Vec2.mk state.offset.x (offsetFromSlider t) }
  | .octaves =>
      let oct := octavesFromSlider t
      { state with config := { state.config with octaves := oct } }
  | .lacunarity =>
      { state with config := { state.config with lacunarity := lacunarityFromSlider t } }
  | .persistence =>
      { state with config := { state.config with persistence := persistenceFromSlider t } }
  | .jitter => { state with jitter := jitterFromSlider t }

def noiseExplorerSliderT (state : NoiseExplorerState) (which : NoiseExplorerSlider) : Float :=
  match which with
  | .scale => scaleToSlider state.scale
  | .offsetX => offsetToSlider state.offset.x
  | .offsetY => offsetToSlider state.offset.y
  | .octaves => octavesToSlider state.config.octaves
  | .lacunarity => lacunarityToSlider state.config.lacunarity
  | .persistence => persistenceToSlider state.config.persistence
  | .jitter => jitterToSlider state.jitter

private def renderSlider (label value : String) (t : Float) (layout : NoiseExplorerSliderLayout)
    (fontSmall : Font) (active : Bool := false) : CanvasM Unit := do
  let t := clamp01 t
  let knobX := layout.x + t * layout.width
  let knobY := layout.y + layout.height / 2.0
  let knobRadius := layout.height * 0.75
  let trackHeight := layout.height * 0.5

  setFillColor (if active then Color.gray 0.7 else Color.gray 0.5)
  fillPath (Afferent.Path.rectangleXYWH layout.x
    (layout.y + layout.height / 2.0 - trackHeight / 2.0)
    layout.width trackHeight)

  setFillColor (if active then Color.yellow else Color.gray 0.85)
  fillPath (Afferent.Path.circle (Point.mk knobX knobY) knobRadius)

  setFillColor (Color.gray 0.75)
  fillTextXY s!"{label}: {value}" layout.x (layout.y - 6.0) fontSmall

private def renderToggle (label : String) (value : Bool) (layout : NoiseExplorerToggleLayout)
    (fontSmall : Font) : CanvasM Unit := do
  let box := Afferent.Path.rectangleXYWH layout.x layout.y layout.size layout.size
  setStrokeColor (Color.gray 0.6)
  setLineWidth 1.5
  strokePath box
  if value then
    setFillColor (Color.rgba 0.3 0.9 0.6 1.0)
    fillPath (Afferent.Path.rectangleXYWH (layout.x + 3) (layout.y + 3)
      (layout.size - 6) (layout.size - 6))
  setFillColor (Color.gray 0.8)
  fillTextXY label (layout.x + layout.size + 8.0) (layout.y + layout.size - 3.0) fontSmall

private def renderDropdown (label : String) (layout : NoiseExplorerDropdownLayout) (isOpen : Bool)
    (fontSmall : Font) : CanvasM Unit := do
  setFillColor (Color.gray 0.15)
  fillPath (Afferent.Path.rectangleXYWH layout.x layout.y layout.width layout.height)
  setStrokeColor (Color.gray 0.4)
  setLineWidth 1.0
  strokePath (Afferent.Path.rectangleXYWH layout.x layout.y layout.width layout.height)
  setFillColor (Color.gray 0.85)
  fillTextXY label (layout.x + 8.0) (layout.y + layout.height - 8.0) fontSmall
  let arrowX := layout.x + layout.width - 16.0
  let arrowY := layout.y + layout.height / 2.0
  let arrow := if isOpen then "^" else "v"
  fillTextXY arrow arrowX (arrowY + 5.0) fontSmall

private def noiseSample01 (state : NoiseExplorerState) (x y : Float) : Float :=
  match state.noiseType with
  | .perlin =>
      let n := if state.useFbm then Noise.fbm2D x y state.config else Noise.perlin2D x y
      Noise.normalize n
  | .simplex =>
      let n := if state.useFbm then Noise.fbmSimplex2D x y state.config else Noise.simplex2D x y
      Noise.normalize n
  | .value =>
      let n := if state.useFbm then Noise.fbmValue2D x y state.config else Noise.value2D x y
      Float.clamp n 0.0 1.0
  | .worley =>
      if state.useFbm then
        let n := Noise.fbmWorley2D x y state.config state.jitter
        let n01 := Float.clamp n 0.0 1.5
        1.0 - n01 / 1.5
      else
        let r := Noise.worley2D x y state.jitter
        let n01 := Float.clamp r.f1 0.0 1.5
        1.0 - n01 / 1.5

private def noiseExplorerCacheKey (state : NoiseExplorerState) (res : Nat) : NoiseExplorerCacheKey := {
  noiseType := state.noiseType
  useFbm := state.useFbm
  scale := state.scale
  offsetX := state.offset.x
  offsetY := state.offset.y
  octaves := state.config.octaves
  lacunarity := state.config.lacunarity
  persistence := state.config.persistence
  jitter := state.jitter
  res := res
}

private def buildNoiseSamples (state : NoiseExplorerState) (res : Nat) : Array Float := Id.run do
  let mut samples : Array Float := Array.mkEmpty (res * res)
  let invRes := if res == 0 then 0.0 else 1.0 / res.toFloat
  for yi in [:res] do
    for xi in [:res] do
      let u := xi.toFloat * invRes - 0.5
      let v := yi.toFloat * invRes - 0.5
      let sx := u * state.scale + state.offset.x
      let sy := v * state.scale + state.offset.y
      samples := samples.push (noiseSample01 state sx sy)
  samples

private def getNoiseSamplesCached (state : NoiseExplorerState) (res : Nat) : IO (Array Float) := do
  let key := noiseExplorerCacheKey state res
  let cache ← noiseExplorerCacheRef.get
  match cache.key with
  | some existing =>
      if existing == key then
        pure cache.samples
      else
        let samples := buildNoiseSamples state res
        noiseExplorerCacheRef.set { key := some key, samples := samples }
        pure samples
  | none =>
      let samples := buildNoiseSamples state res
      noiseExplorerCacheRef.set { key := some key, samples := samples }
      pure samples

private def noiseExplorerRectBatchKey (state : NoiseExplorerState) (res : Nat)
    (plotW plotH originX originY : Float) : NoiseExplorerRectBatchKey := {
  sampleKey := noiseExplorerCacheKey state res
  plotW := plotW
  plotH := plotH
  originX := originX
  originY := originY
}

private def buildNoiseRectBatchData (samples : Array Float) (res : Nat)
    (plotW plotH originX originY : Float) : Array Float := Id.run do
  let mut data : Array Float := Array.mkEmpty (res * res * 9)
  if res == 0 then
    return data
  let cellW := plotW / res.toFloat
  let cellH := plotH / res.toFloat
  for yi in [:res] do
    for xi in [:res] do
      let idx := yi * res + xi
      let n01 := samples.getD idx 0.0
      let x := originX + xi.toFloat * cellW
      let y := originY + yi.toFloat * cellH
      data := data
        |>.push x |>.push y |>.push (cellW + 0.5) |>.push (cellH + 0.5)
        |>.push n01 |>.push n01 |>.push n01 |>.push 1.0 |>.push 0.0
  data

private def getNoiseRectBatchDataCached (state : NoiseExplorerState) (res : Nat)
    (samples : Array Float) (plotW plotH originX originY : Float) : IO (Array Float × Nat) := do
  let key := noiseExplorerRectBatchKey state res plotW plotH originX originY
  let cache ← noiseExplorerRectBatchCacheRef.get
  match cache.key with
  | some existing =>
      if existing == key then
        pure (cache.data, cache.count)
      else
        let data := buildNoiseRectBatchData samples res plotW plotH originX originY
        let count := res * res
        noiseExplorerRectBatchCacheRef.set { key := some key, data := data, count := count }
        pure (data, count)
  | none =>
      let data := buildNoiseRectBatchData samples res plotW plotH originX originY
      let count := res * res
      noiseExplorerRectBatchCacheRef.set { key := some key, data := data, count := count }
      pure (data, count)

/-- Render noise explorer. -/
def renderNoiseExplorer2D (state : NoiseExplorerState)
    (view : MathView2D.View) (screenScale : Float) (fontMedium fontSmall : Font) : CanvasM Unit := do
  let w := view.width
  let h := view.height
  let panelW := panelWidth screenScale
  let plotW := w - panelW
  let plotH := h

  -- Background
  setFillColor (Color.gray 0.08)
  fillPath (Afferent.Path.rectangleXYWH 0 0 plotW plotH)

  let dragging := match state.dragging with
    | .slider _ => true
    | .none => false
  let cellSize := (if dragging then 10.0 else 6.0) * screenScale
  let resX := floorToNat (plotW / cellSize)
  let resY := floorToNat (plotH / cellSize)
  let minRes := if dragging then 24 else 32
  let maxRes := if dragging then 64 else 96
  let res := Nat.max minRes (Nat.min maxRes (Nat.min resX resY))
  let cellW := plotW / res.toFloat
  let cellH := plotH / res.toFloat
  let samples ← getNoiseSamplesCached state res
  let canvas ← getCanvas
  let t := canvas.state.transform
  let near : Float → Float → Bool := fun a b => Float.abs (a - b) < 0.0001
  let axisAlignedTranslateOnly := near t.a 1.0 && near t.b 0.0 && near t.c 0.0 && near t.d 1.0

  if axisAlignedTranslateOnly then
    let (batchData, batchCount) ← getNoiseRectBatchDataCached state res samples plotW plotH t.tx t.ty
    if batchCount > 0 then
      let renderer := canvas.ctx.renderer
      let (canvasW, canvasH) ← canvas.ctx.getCurrentSize
      renderer.drawBatch 0 batchData batchCount.toUInt32 0.0 0.0 canvasW canvasH
  else
    for yi in [:res] do
      for xi in [:res] do
        let idx := yi * res + xi
        let n01 := samples.getD idx 0.0
        setFillColor (Color.gray n01)
        fillPath (Afferent.Path.rectangleXYWH (xi.toFloat * cellW) (yi.toFloat * cellH)
          (cellW + 0.5) (cellH + 0.5))

  setStrokeColor (Color.gray 0.3)
  setLineWidth 1.0
  strokePath (Afferent.Path.rectangleXYWH 0 0 plotW plotH)

  -- Panel background
  let pX := panelX w screenScale
  setFillColor (Color.rgba 0.08 0.08 0.1 0.95)
  fillPath (Afferent.Path.rectangleXYWH pX 0 panelW h)

  -- Title
  setFillColor VecColor.label
  fillTextXY "NOISE EXPLORER 2D" (pX + 20 * screenScale) (40 * screenScale) fontMedium
  setFillColor (Color.gray 0.6)
  fillTextXY "Perlin / Simplex / Value / Worley" (pX + 20 * screenScale) (62 * screenScale) fontSmall

  let drop := noiseExplorerDropdownLayout w h screenScale
  renderDropdown s!"Noise: {state.noiseType.label}" drop state.dropdownOpen fontSmall
  if state.dropdownOpen then
    for i in [:noiseExplorerOptions.size] do
      let opt := noiseExplorerOptions.getD i .perlin
      let optLayout := noiseExplorerDropdownOptionLayout drop i
      setFillColor (if opt == state.noiseType then Color.rgba 0.2 0.5 0.8 0.6 else Color.gray 0.18)
      fillPath (Afferent.Path.rectangleXYWH optLayout.x optLayout.y optLayout.width optLayout.height)
      setFillColor (if opt == state.noiseType then Color.white else Color.gray 0.75)
      fillTextXY opt.label (optLayout.x + 8.0) (optLayout.y + optLayout.height - 8.0) fontSmall

  let toggle := noiseExplorerFbmToggleLayout w h screenScale
  renderToggle "Use FBM" state.useFbm toggle fontSmall

  let sliders : Array NoiseExplorerSlider := #[
    .scale, .offsetX, .offsetY, .octaves, .lacunarity, .persistence, .jitter
  ]
  for i in [:sliders.size] do
    let which := sliders.getD i .scale
    let layout := noiseExplorerSliderLayout w h screenScale i
    let t := noiseExplorerSliderT state which
    let active := match state.dragging with
      | .slider s => s == which
      | _ => false
    renderSlider (sliderLabel which) (sliderValueLabel state which) t layout fontSmall active

  setFillColor (Color.gray 0.6)
  fillTextXY "Drag sliders to adjust" (pX + 20 * screenScale)
    (h - 50 * screenScale) fontSmall
  fillTextXY "R: reset" (pX + 20 * screenScale) (h - 30 * screenScale) fontSmall

/-- Create the noise explorer widget. -/
def noiseExplorer2DWidget (env : DemoEnv) (state : NoiseExplorerState)
    : Afferent.Arbor.WidgetBuilder := do
  let config := noiseExplorerMathViewConfig env.screenScale
  MathView2D.mathView2D config env.fontSmall (fun view => do
    renderNoiseExplorer2D state view env.screenScale env.fontMedium env.fontSmall
  )

end Demos.Linalg
