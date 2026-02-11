/-
  Noise Explorer 2D - Visualize Perlin, Simplex, Value, and Worley noise.
  Side-panel controls are provided by Canopy widgets in the tab module.
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

structure NoiseExplorerState where
  noiseType : NoiseType := .perlin
  useFbm : Bool := true
  scale : Float := 2.4
  offset : Vec2 := Vec2.zero
  config : Noise.FractalConfig := {}
  jitter : Float := 1.0
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

def noiseExplorerOptions : Array NoiseType := #[.perlin, .simplex, .value, .worley]

def noiseExplorerOptionAt (idx : Nat) : NoiseType :=
  noiseExplorerOptions.getD idx .perlin

def noiseExplorerOptionIndex (noiseType : NoiseType) : Nat :=
  noiseExplorerOptions.findIdx? (fun opt => opt == noiseType) |>.getD 0

def noiseExplorerOptionLabels : Array String :=
  noiseExplorerOptions.map (fun opt => opt.label)

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

def noiseExplorerSliderLabel (which : NoiseExplorerSlider) : String :=
  match which with
  | .scale => "Scale"
  | .offsetX => "Offset X"
  | .offsetY => "Offset Y"
  | .octaves => "Octaves"
  | .lacunarity => "Lacunarity"
  | .persistence => "Persistence"
  | .jitter => "Jitter"

def noiseExplorerSliderValueLabel (state : NoiseExplorerState) (which : NoiseExplorerSlider) : String :=
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

/-- Render only the noise visualization area (no side-panel controls). -/
def renderNoiseExplorer2D (state : NoiseExplorerState)
    (view : MathView2D.View) (screenScale : Float) : CanvasM Unit := do
  let plotW := view.width
  let plotH := view.height

  setFillColor (Color.gray 0.08)
  fillPath (Afferent.Path.rectangleXYWH 0 0 plotW plotH)

  let cellSize := 6.0 * screenScale
  let resX := floorToNat (plotW / cellSize)
  let resY := floorToNat (plotH / cellSize)
  let res := Nat.max 32 (Nat.min 96 (Nat.min resX resY))
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
    let cellW := plotW / res.toFloat
    let cellH := plotH / res.toFloat
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

/-- Create the noise explorer visualization widget. -/
def noiseExplorer2DWidget (env : DemoEnv) (state : NoiseExplorerState)
    : Afferent.Arbor.WidgetBuilder := do
  let config := noiseExplorerMathViewConfig env.screenScale
  MathView2D.mathView2D config env.fontSmall (fun view => do
    renderNoiseExplorer2D state view env.screenScale
  )

end Demos.Linalg
