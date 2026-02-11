/-
  Worley Cellular Noise - Visualize Worley F1/F2 distances and feature points.
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

inductive WorleyMode where
  | f1
  | f2
  | f2f1
  | f3f1
  deriving BEq, Inhabited

structure WorleyCellularState where
  mode : WorleyMode := .f1
  jitter : Float := 1.0
  showEdges : Bool := true
  showPoints : Bool := true
  showConnections : Bool := false
  deriving Inhabited

def worleyCellularInitialState : WorleyCellularState := {}

def worleyCellularMathViewConfig (screenScale : Float) : MathView2D.Config := {
  style := { flexItem := some (Trellis.FlexItem.growing 1) }
  scale := 80.0 * screenScale
  showGrid := false
  showAxes := false
  showLabels := false
}

def worleyModeOptions : Array WorleyMode := #[.f1, .f2, .f2f1, .f3f1]

def worleyModeOptionAt (idx : Nat) : WorleyMode :=
  worleyModeOptions.getD idx .f1

def worleyModeOptionIndex (mode : WorleyMode) : Nat :=
  worleyModeOptions.findIdx? (fun opt => opt == mode) |>.getD 0

private def clamp01 (t : Float) : Float :=
  Float.clamp t 0.0 1.0

def worleyJitterFromSlider (t : Float) : Float :=
  clamp01 t

private def jitterToSlider (v : Float) : Float :=
  clamp01 v

def worleyJitterSliderT (state : WorleyCellularState) : Float :=
  jitterToSlider state.jitter

def worleyApplyJitterSlider (state : WorleyCellularState) (t : Float) : WorleyCellularState :=
  { state with jitter := worleyJitterFromSlider t }

def worleyJitterLabel (state : WorleyCellularState) : String :=
  formatFloat state.jitter

def WorleyMode.label : WorleyMode -> String
  | .f1 => "F1"
  | .f2 => "F2"
  | .f2f1 => "F2 - F1"
  | .f3f1 => "F3 - F1"

def worleyModeOptionLabels : Array String :=
  worleyModeOptions.map (fun opt => opt.label)

private structure WorleySampleCacheKey where
  mode : WorleyMode
  jitter : Float
  showEdges : Bool
  scale : Float
  res : Nat
  deriving BEq, Inhabited

private structure WorleySampleCache where
  key : Option WorleySampleCacheKey := none
  samples : Array Float := #[]
  deriving Inhabited

initialize worleySampleCacheRef : IO.Ref WorleySampleCache ← IO.mkRef {}

private structure WorleyRectBatchKey where
  sampleKey : WorleySampleCacheKey
  plotW : Float
  plotH : Float
  originX : Float
  originY : Float
  deriving BEq, Inhabited

private structure WorleyRectBatchCache where
  key : Option WorleyRectBatchKey := none
  data : Array Float := #[]
  count : Nat := 0
  deriving Inhabited

initialize worleyRectBatchCacheRef : IO.Ref WorleyRectBatchCache ← IO.mkRef {}

-- Permutation table (copied from Linalg.Noise to match feature points).
private def permTable : Array UInt8 := #[
  151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
  140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
  247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
  57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175,
  74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122,
  60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
  65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
  200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64,
  52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212,
  207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213,
  119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
  129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104,
  218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241,
  81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157,
  184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93,
  222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
]

@[inline]
private def perm (i : Int) : UInt8 :=
  let idx := (i % 256 + 256) % 256
  permTable.getD idx.toNat 0

@[inline]
private def worleyHash (i j : Int) (n : Nat) : Float :=
  let h := perm (i + (perm j).toNat * 17 + n * 31)
  h.toFloat / 255.0

@[inline]
private def intToFloat (i : Int) : Float :=
  if i >= 0 then i.toNat.toFloat else -((-i).toNat.toFloat)

private def floatToInt (f : Float) : Int :=
  if f >= 0.0 then Int.ofNat (f.toUInt64.toNat)
  else -Int.ofNat ((-f).toUInt64.toNat)

private def featurePoint (ci cj : Int) (jitter : Float) : Vec2 :=
  let px := intToFloat ci + worleyHash ci cj 0 * jitter
  let py := intToFloat cj + worleyHash ci cj 1 * jitter
  Vec2.mk px py

private def floorToNat (x : Float) : Nat :=
  (Float.floor x).toUInt64.toNat

private def worleySampleCacheKey (state : WorleyCellularState) (scale : Float) (res : Nat)
    : WorleySampleCacheKey := {
  mode := state.mode
  jitter := state.jitter
  showEdges := state.showEdges
  scale := scale
  res := res
}

private def worleySample01 (state : WorleyCellularState) (sx sy : Float) : Float :=
  let r := Noise.worley2D sx sy state.jitter
  let value := match state.mode with
    | .f1 => r.f1
    | .f2 => r.f2
    | .f2f1 => r.f2 - r.f1
    | .f3f1 => r.f3 - r.f1
  let n01 := Float.clamp (1.0 - value / 1.6) 0.0 1.0
  if state.showEdges then
    let edge01 := Float.clamp ((r.f2 - r.f1) * 3.0) 0.0 1.0
    Float.clamp (n01 + edge01 * 0.7) 0.0 1.0
  else
    n01

private def buildWorleySamples (state : WorleyCellularState) (scale : Float) (res : Nat) : Array Float := Id.run do
  let mut samples : Array Float := Array.mkEmpty (res * res)
  let invRes := if res == 0 then 0.0 else 1.0 / res.toFloat
  for yi in [:res] do
    for xi in [:res] do
      let u := xi.toFloat * invRes - 0.5
      let v := yi.toFloat * invRes - 0.5
      let sx := u * scale
      let sy := v * scale
      samples := samples.push (worleySample01 state sx sy)
  samples

private def getWorleySamplesCached (state : WorleyCellularState) (scale : Float) (res : Nat)
    : IO (Array Float) := do
  let key := worleySampleCacheKey state scale res
  let cache ← worleySampleCacheRef.get
  match cache.key with
  | some existing =>
      if existing == key then
        pure cache.samples
      else
        let samples := buildWorleySamples state scale res
        worleySampleCacheRef.set { key := some key, samples := samples }
        pure samples
  | none =>
      let samples := buildWorleySamples state scale res
      worleySampleCacheRef.set { key := some key, samples := samples }
      pure samples

private def worleyRectBatchKey (state : WorleyCellularState) (scale : Float) (res : Nat)
    (plotW plotH originX originY : Float) : WorleyRectBatchKey := {
  sampleKey := worleySampleCacheKey state scale res
  plotW := plotW
  plotH := plotH
  originX := originX
  originY := originY
}

private def buildWorleyRectBatchData (samples : Array Float) (res : Nat)
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

private def getWorleyRectBatchDataCached (state : WorleyCellularState) (scale : Float) (res : Nat)
    (samples : Array Float) (plotW plotH originX originY : Float) : IO (Array Float × Nat) := do
  let key := worleyRectBatchKey state scale res plotW plotH originX originY
  let cache ← worleyRectBatchCacheRef.get
  match cache.key with
  | some existing =>
      if existing == key then
        pure (cache.data, cache.count)
      else
        let data := buildWorleyRectBatchData samples res plotW plotH originX originY
        let count := res * res
        worleyRectBatchCacheRef.set { key := some key, data := data, count := count }
        pure (data, count)
  | none =>
      let data := buildWorleyRectBatchData samples res plotW plotH originX originY
      let count := res * res
      worleyRectBatchCacheRef.set { key := some key, data := data, count := count }
      pure (data, count)

structure WorleyPoint where
  cellX : Int
  cellY : Int
  pos : Vec2

def renderWorleyCellular (state : WorleyCellularState)
    (view : MathView2D.View) (screenScale : Float) : CanvasM Unit := do
  let plotW := view.width
  let plotH := view.height

  setFillColor (Color.gray 0.08)
  fillPath (Afferent.Path.rectangleXYWH 0 0 plotW plotH)

  let scale := 3.4
  let cellSize := 6.0 * screenScale
  let resX := floorToNat (plotW / cellSize)
  let resY := floorToNat (plotH / cellSize)
  let res := Nat.max 32 (Nat.min 96 (Nat.min resX resY))
  let samples ← getWorleySamplesCached state scale res

  let canvas ← getCanvas
  let t := canvas.state.transform
  let near : Float → Float → Bool := fun a b => Float.abs (a - b) < 0.0001
  let axisAlignedTranslateOnly := near t.a 1.0 && near t.b 0.0 && near t.c 0.0 && near t.d 1.0

  if axisAlignedTranslateOnly then
    let (batchData, batchCount) ← getWorleyRectBatchDataCached state scale res samples plotW plotH t.tx t.ty
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

  if state.showPoints || state.showConnections then
    let minX := -0.5 * scale
    let maxX := 0.5 * scale
    let minCell := floatToInt (Float.floor minX) - 1
    let maxCell := floatToInt (Float.floor maxX) + 1
    let mut points : Array WorleyPoint := #[]
    let mut ci := minCell
    while ci <= maxCell do
      let mut cj := minCell
      while cj <= maxCell do
        let p := featurePoint ci cj state.jitter
        points := points.push { cellX := ci, cellY := cj, pos := p }
        cj := cj + 1
      ci := ci + 1

    let worldToScreen := fun (p : Vec2) =>
      let u := p.x / scale + 0.5
      let v := p.y / scale + 0.5
      (u * plotW, v * plotH)

    if state.showConnections then
      setStrokeColor (Color.rgba 0.8 0.6 0.2 0.4)
      setLineWidth (1.0 * screenScale)
      for i in [:points.size] do
        let p := points.getD i { cellX := 0, cellY := 0, pos := Vec2.zero }
        let mut bestDist := Float.infinity
        let mut best : Option WorleyPoint := none
        for j in [:points.size] do
          if i != j then
            let q := points.getD j { cellX := 0, cellY := 0, pos := Vec2.zero }
            let d := (p.pos - q.pos).length
            if d < bestDist then
              bestDist := d
              best := some q
        match best with
        | some q =>
            if bestDist < 1.8 then
              let a := worldToScreen p.pos
              let b := worldToScreen q.pos
              let path := Afferent.Path.empty
                |>.moveTo (Point.mk a.1 a.2)
                |>.lineTo (Point.mk b.1 b.2)
              strokePath path
        | none => pure ()

    if state.showPoints then
      for p in points do
        let s := worldToScreen p.pos
        setFillColor (Color.rgba 0.95 0.4 0.2 0.9)
        fillPath (Afferent.Path.circle (Point.mk s.1 s.2) (3.0 * screenScale))

  setStrokeColor (Color.gray 0.35)
  setLineWidth 1.0
  strokePath (Afferent.Path.rectangleXYWH 0 0 plotW plotH)

/-- Create worley cellular widget. -/
def worleyCellularNoiseWidget (env : DemoEnv) (state : WorleyCellularState)
    : Afferent.Arbor.WidgetBuilder := do
  let config := worleyCellularMathViewConfig env.screenScale
  MathView2D.mathView2D config env.fontSmall (fun view => do
    renderWorleyCellular state view env.screenScale
  )

end Demos.Linalg
