/-
  Domain Warping Demo - Before/after comparison of warped noise.
  Shows warp vectors and animated evolution.
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

inductive WarpingSlider where
  | strength1
  | strength2
  | scale
  | speed
  deriving BEq, Inhabited

structure DomainWarpingState where
  strength1 : Float := 3.0
  strength2 : Float := 4.5
  scale : Float := 2.3
  speed : Float := 0.25
  animate : Bool := true
  showVectors : Bool := true
  useAdvanced : Bool := false
  time : Float := 0.0
  lastTime : Float := 0.0
  deriving Inhabited

def domainWarpingInitialState : DomainWarpingState := {}

def domainWarpingMathViewConfig (screenScale : Float) : MathView2D.Config := {
  style := { flexItem := some (Trellis.FlexItem.growing 1) }
  scale := 80.0 * screenScale
  showGrid := false
  showAxes := false
  showLabels := false
}

private def clamp01 (t : Float) : Float :=
  Float.clamp t 0.0 1.0

private def strengthFromSlider (t : Float) : Float :=
  0.5 + 7.5 * t

private def strengthToSlider (v : Float) : Float :=
  clamp01 ((v - 0.5) / 7.5)

private def scaleFromSlider (t : Float) : Float :=
  0.6 + 4.4 * t

private def scaleToSlider (v : Float) : Float :=
  clamp01 ((v - 0.6) / 4.4)

private def speedFromSlider (t : Float) : Float :=
  0.05 + 0.9 * t

private def speedToSlider (v : Float) : Float :=
  clamp01 ((v - 0.05) / 0.9)

def domainWarpingSliderOrder : Array WarpingSlider := #[
  .strength1, .strength2, .scale, .speed
]

def domainWarpingSliderLabel (which : WarpingSlider) : String :=
  match which with
  | .strength1 => "Strength 1"
  | .strength2 => "Strength 2"
  | .scale => "Scale"
  | .speed => "Speed"

def domainWarpingSliderValueLabel (state : DomainWarpingState) (which : WarpingSlider) : String :=
  match which with
  | .strength1 => formatFloat state.strength1
  | .strength2 => formatFloat state.strength2
  | .scale => formatFloat state.scale
  | .speed => formatFloat state.speed

def domainWarpingApplySlider (state : DomainWarpingState) (which : WarpingSlider) (t : Float)
    : DomainWarpingState :=
  let t := clamp01 t
  match which with
  | .strength1 => { state with strength1 := strengthFromSlider t }
  | .strength2 => { state with strength2 := strengthFromSlider t }
  | .scale => { state with scale := scaleFromSlider t }
  | .speed => { state with speed := speedFromSlider t }

def domainWarpingSliderT (state : DomainWarpingState) (which : WarpingSlider) : Float :=
  match which with
  | .strength1 => strengthToSlider state.strength1
  | .strength2 => strengthToSlider state.strength2
  | .scale => scaleToSlider state.scale
  | .speed => speedToSlider state.speed

private structure DomainWarpSampleCacheKey where
  useWarp : Bool
  useAdvanced : Bool
  strength1 : Float
  strength2 : Float
  scale : Float
  time : Float
  res : Nat
  deriving BEq, Inhabited

private structure DomainWarpSampleCacheEntry where
  key : Option DomainWarpSampleCacheKey := none
  samples : Array Float := #[]
  deriving Inhabited

private structure DomainWarpSampleCache where
  base : DomainWarpSampleCacheEntry := {}
  warped : DomainWarpSampleCacheEntry := {}
  deriving Inhabited

initialize domainWarpSampleCacheRef : IO.Ref DomainWarpSampleCache ← IO.mkRef {}

private structure DomainWarpRectBatchKey where
  sampleKey : DomainWarpSampleCacheKey
  x : Float
  y : Float
  w : Float
  h : Float
  originX : Float
  originY : Float
  deriving BEq, Inhabited

private structure DomainWarpRectBatchCacheEntry where
  key : Option DomainWarpRectBatchKey := none
  data : Array Float := #[]
  count : Nat := 0
  deriving Inhabited

private structure DomainWarpRectBatchCache where
  base : DomainWarpRectBatchCacheEntry := {}
  warped : DomainWarpRectBatchCacheEntry := {}
  deriving Inhabited

initialize domainWarpRectBatchCacheRef : IO.Ref DomainWarpRectBatchCache ← IO.mkRef {}

private def floorToNat (x : Float) : Nat :=
  (Float.floor x).toUInt64.toNat

private def domainWarpSampleCacheKey (state : DomainWarpingState) (time : Float) (useWarp : Bool)
    (res : Nat) : DomainWarpSampleCacheKey := {
  useWarp := useWarp
  useAdvanced := state.useAdvanced
  strength1 := state.strength1
  strength2 := state.strength2
  scale := state.scale
  time := time
  res := res
}

private def domainWarpSample01 (state : DomainWarpingState) (time sx sy : Float) (useWarp : Bool) : Float :=
  let sx := sx + time * 0.2
  let sy := sy + time * 0.15
  let n := if useWarp then
    if state.useAdvanced then
      Noise.warp2DAdvanced sx sy state.strength1 state.strength2
    else
      Noise.warp2D sx sy state.strength1
  else
    Noise.fbm2D sx sy
  Noise.normalize n

private def buildDomainWarpSamples (state : DomainWarpingState) (time : Float)
    (useWarp : Bool) (res : Nat) : Array Float := Id.run do
  let mut samples : Array Float := Array.mkEmpty (res * res)
  let invRes := if res == 0 then 0.0 else 1.0 / res.toFloat
  for yi in [:res] do
    for xi in [:res] do
      let u := xi.toFloat * invRes - 0.5
      let v := yi.toFloat * invRes - 0.5
      let sx := u * state.scale
      let sy := v * state.scale
      samples := samples.push (domainWarpSample01 state time sx sy useWarp)
  samples

private def getDomainWarpSamplesCached (state : DomainWarpingState) (time : Float)
    (useWarp : Bool) (res : Nat) : IO (Array Float) := do
  let key := domainWarpSampleCacheKey state time useWarp res
  let cache ← domainWarpSampleCacheRef.get
  let slot := if useWarp then cache.warped else cache.base
  match slot.key with
  | some existing =>
      if existing == key then
        pure slot.samples
      else
        let samples := buildDomainWarpSamples state time useWarp res
        let newSlot : DomainWarpSampleCacheEntry := { key := some key, samples := samples }
        if useWarp then
          domainWarpSampleCacheRef.set { cache with warped := newSlot }
        else
          domainWarpSampleCacheRef.set { cache with base := newSlot }
        pure samples
  | none =>
      let samples := buildDomainWarpSamples state time useWarp res
      let newSlot : DomainWarpSampleCacheEntry := { key := some key, samples := samples }
      if useWarp then
        domainWarpSampleCacheRef.set { cache with warped := newSlot }
      else
        domainWarpSampleCacheRef.set { cache with base := newSlot }
      pure samples

private def domainWarpRectBatchKey (state : DomainWarpingState) (time : Float) (useWarp : Bool)
    (res : Nat) (x y w h originX originY : Float) : DomainWarpRectBatchKey := {
  sampleKey := domainWarpSampleCacheKey state time useWarp res
  x := x
  y := y
  w := w
  h := h
  originX := originX
  originY := originY
}

private def buildDomainWarpRectBatchData (samples : Array Float) (x y w h : Float) (res : Nat)
    (originX originY : Float) : Array Float := Id.run do
  let mut data : Array Float := Array.mkEmpty (res * res * 9)
  if res == 0 then
    return data
  let cellW := w / res.toFloat
  let cellH := h / res.toFloat
  for yi in [:res] do
    for xi in [:res] do
      let idx := yi * res + xi
      let n01 := samples.getD idx 0.0
      let px := originX + x + xi.toFloat * cellW
      let py := originY + y + yi.toFloat * cellH
      data := data
        |>.push px |>.push py |>.push (cellW + 0.5) |>.push (cellH + 0.5)
        |>.push n01 |>.push n01 |>.push n01 |>.push 1.0 |>.push 0.0
  data

private def getDomainWarpRectBatchDataCached (state : DomainWarpingState) (time : Float)
    (useWarp : Bool) (res : Nat) (samples : Array Float)
    (x y w h originX originY : Float) : IO (Array Float × Nat) := do
  let key := domainWarpRectBatchKey state time useWarp res x y w h originX originY
  let cache ← domainWarpRectBatchCacheRef.get
  let slot := if useWarp then cache.warped else cache.base
  match slot.key with
  | some existing =>
      if existing == key then
        pure (slot.data, slot.count)
      else
        let data := buildDomainWarpRectBatchData samples x y w h res originX originY
        let count := res * res
        let newSlot : DomainWarpRectBatchCacheEntry := { key := some key, data := data, count := count }
        if useWarp then
          domainWarpRectBatchCacheRef.set { cache with warped := newSlot }
        else
          domainWarpRectBatchCacheRef.set { cache with base := newSlot }
        pure (data, count)
  | none =>
      let data := buildDomainWarpRectBatchData samples x y w h res originX originY
      let count := res * res
      let newSlot : DomainWarpRectBatchCacheEntry := { key := some key, data := data, count := count }
      if useWarp then
        domainWarpRectBatchCacheRef.set { cache with warped := newSlot }
      else
        domainWarpRectBatchCacheRef.set { cache with base := newSlot }
      pure (data, count)

private def renderNoisePanel (x y w h : Float) (label : String)
    (state : DomainWarpingState) (time : Float)
    (screenScale : Float) (fontSmall : Font) (useWarp : Bool) : CanvasM Unit := do
  setFillColor (Color.gray 0.08)
  fillPath (Afferent.Path.rectangleXYWH x y w h)

  let cellSize := 6.0 * screenScale
  let resX := floorToNat (w / cellSize)
  let resY := floorToNat (h / cellSize)
  let res := Nat.max 28 (Nat.min 72 (Nat.min resX resY))
  let samples ← getDomainWarpSamplesCached state time useWarp res

  let canvas ← getCanvas
  let t := canvas.state.transform
  let near : Float → Float → Bool := fun a b => Float.abs (a - b) < 0.0001
  let axisAlignedTranslateOnly := near t.a 1.0 && near t.b 0.0 && near t.c 0.0 && near t.d 1.0

  if axisAlignedTranslateOnly then
    let (batchData, batchCount) ← getDomainWarpRectBatchDataCached
      state time useWarp res samples x y w h t.tx t.ty
    if batchCount > 0 then
      let renderer := canvas.ctx.renderer
      let (canvasW, canvasH) ← canvas.ctx.getCurrentSize
      renderer.drawBatch 0 batchData batchCount.toUInt32 0.0 0.0 canvasW canvasH
  else
    let cellW := w / res.toFloat
    let cellH := h / res.toFloat
    for yi in [:res] do
      for xi in [:res] do
        let idx := yi * res + xi
        let n01 := samples.getD idx 0.0
        setFillColor (Color.gray n01)
        fillPath (Afferent.Path.rectangleXYWH (x + xi.toFloat * cellW) (y + yi.toFloat * cellH)
          (cellW + 0.5) (cellH + 0.5))

  setStrokeColor (Color.gray 0.35)
  setLineWidth 1.0
  strokePath (Afferent.Path.rectangleXYWH x y w h)

  setFillColor (Color.gray 0.8)
  fillTextXY label (x + 8.0) (y + 18.0) fontSmall

private def renderWarpVectors (x y w h : Float) (state : DomainWarpingState) (time : Float)
    (screenScale : Float) : CanvasM Unit := do
  let grid := 8
  let stepX := w / grid.toFloat
  let stepY := h / grid.toFloat
  for i in [:grid + 1] do
    for j in [:grid + 1] do
      let px := x + i.toFloat * stepX
      let py := y + j.toFloat * stepY
      let u := (px - x) / w - 0.5
      let v := (py - y) / h - 0.5
      let sx := u * state.scale + time * 0.2
      let sy := v * state.scale + time * 0.15
      let qx := Noise.fbm2D sx sy
      let qy := Noise.fbm2D (sx + 5.2) (sy + 1.3)
      let vec := Vec2.mk qx qy * (state.strength1 * 0.35)
      let endX := px + vec.x * stepX
      let endY := py - vec.y * stepY
      drawArrow2D (px, py) (endX, endY) {
        color := Color.rgba 0.9 0.7 0.2 0.7
        lineWidth := 1.2 * screenScale
        headLength := 6.0 * screenScale
        headAngle := 0.6
      }

/-- Render domain warping demo. -/
def renderDomainWarpingDemo (state : DomainWarpingState)
    (view : MathView2D.View) (screenScale : Float) (fontSmall : Font) : CanvasM Unit := do
  let w := view.width
  let h := view.height
  let contentW := w
  let pad := 18.0 * screenScale
  let viewW := (contentW - pad * 3.0) / 2.0
  let viewH := h - pad * 2.0
  let leftX := pad
  let rightX := pad * 2.0 + viewW
  let viewY := pad
  let t := state.time

  renderNoisePanel leftX viewY viewW viewH "Base FBM" state t screenScale fontSmall false
  renderNoisePanel rightX viewY viewW viewH "Warped" state t screenScale fontSmall true

  if state.showVectors then
    renderWarpVectors leftX viewY viewW viewH state t screenScale

/-- Create the domain warping widget. -/
def domainWarpingDemoWidget (env : DemoEnv) (state : DomainWarpingState)
    : Afferent.Arbor.WidgetBuilder := do
  let config := domainWarpingMathViewConfig env.screenScale
  MathView2D.mathView2D config env.fontSmall (fun view => do
    renderDomainWarpingDemo state view env.screenScale env.fontSmall
  )

end Demos.Linalg
