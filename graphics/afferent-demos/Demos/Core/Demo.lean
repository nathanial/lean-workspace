/-
  Demo Typeclass - Shared demo environment and polymorphic demo handling.
-/
import Afferent
import Afferent.UI.Arbor
import Init.Data.FloatArray
import Trellis
import Std.Data.HashMap

open Afferent

namespace Demos

structure RunnerStats where
  frameMs : Float := 0.0
  fps : Float := 0.0
  beginFrameMs : Float := 0.0
  preInputMs : Float := 0.0
  inputMs : Float := 0.0
  reactiveMs : Float := 0.0
  reactivePropagateMs : Float := 0.0
  reactiveRenderMs : Float := 0.0
  sizeMs : Float := 0.0
  buildMs : Float := 0.0
  layoutMs : Float := 0.0
  indexMs : Float := 0.0
  collectMs : Float := 0.0
  nameSyncMs : Float := 0.0
  syncOverheadMs : Float := 0.0
  executeMs : Float := 0.0
  canvasSwapMs : Float := 0.0
  stateSwapMs : Float := 0.0
  endFrameMs : Float := 0.0
  gapAfterLayoutMs : Float := 0.0
  gapBeforeSyncMs : Float := 0.0
  gapBeforeExecuteMs : Float := 0.0
  gapBeforeCanvasSwapMs : Float := 0.0
  gapBeforeEndFrameMs : Float := 0.0
  gapBeforeStateSwapMs : Float := 0.0
  indexCollectEnvelopeMs : Float := 0.0
  indexCollectOverheadMs : Float := 0.0
  boundaryGapTotalMs : Float := 0.0
  residualUnaccountedMs : Float := 0.0
  accountedMs : Float := 0.0
  unaccountedMs : Float := 0.0
  commandCount : Nat := 0
  coalescedCommandCount : Nat := 0
  drawCalls : Nat := 0
  batchedCalls : Nat := 0
  individualCalls : Nat := 0
  rectsBatched : Nat := 0
  circlesBatched : Nat := 0
  strokeRectsBatched : Nat := 0
  linesBatched : Nat := 0
  textsBatched : Nat := 0
  flattenMs : Float := 0.0
  coalesceMs : Float := 0.0
  batchLoopMs : Float := 0.0
  drawCallMs : Float := 0.0
  cacheHits : Nat := 0
  cacheMisses : Nat := 0
  voluntaryCtxSwitchesDelta : UInt64 := 0
  involuntaryCtxSwitchesDelta : UInt64 := 0
  minorPageFaultsDelta : UInt64 := 0
  majorPageFaultsDelta : UInt64 := 0
  widgetCount : Nat := 0
  layoutCount : Nat := 0
  probeCollectFirstThisFrame : Bool := false
  probeIndexFirstSamples : Nat := 0
  probeCollectFirstSamples : Nat := 0
  probeIndexWhenFirstAvgMs : Float := 0.0
  probeIndexWhenSecondAvgMs : Float := 0.0
  probeCollectWhenFirstAvgMs : Float := 0.0
  probeCollectWhenSecondAvgMs : Float := 0.0
  probeIndexSecondPenaltyMs : Float := 0.0
  probeCollectSecondPenaltyMs : Float := 0.0
  deriving Inhabited

structure DemoEnv where
  /-- Runner stats shared with the Canopy footer widget. -/
  statsRef : IO.Ref RunnerStats
  screenScale : Float
  t : Float
  dt : Float
  keyCode : UInt16
  clearKey : IO Unit
  window : Afferent.FFI.Window
  fontSmall : Afferent.Font
  fontMedium : Afferent.Font
  fontLarge : Afferent.Font
  fontHuge : Afferent.Font
  fontCanopy : Afferent.Font
  fontCanopySmall : Afferent.Font
  layoutFont : Afferent.Font
  fontRegistry : Afferent.FontRegistry
  fontMediumId : Afferent.Arbor.FontId
  fontSmallId : Afferent.Arbor.FontId
  fontLargeId : Afferent.Arbor.FontId
  fontHugeId : Afferent.Arbor.FontId
  fontCanopyId : Afferent.Arbor.FontId
  fontCanopySmallId : Afferent.Arbor.FontId
  /-- Font showcase fonts keyed by "family-size" (e.g., "monaco-12", "helvetica-36") -/
  showcaseFonts : Std.HashMap String Afferent.Arbor.FontId
  spriteTexture : Afferent.FFI.Texture
  circleRadius : Float
  spriteHalfSize : Float
  lineBuffer : Afferent.FFI.Buffer
  lineCount : Nat
  lineWidth : Float
  orbitalCount : Nat
  orbitalParams : FloatArray
  orbitalBuffer : Afferent.FFI.FloatBuffer
  windowWidthF : Float
  windowHeightF : Float
  physWidthF : Float
  physHeightF : Float
  physWidth : UInt32
  physHeight : UInt32
  contentOffsetX : Float
  contentOffsetY : Float
  layoutOffsetX : Float
  layoutOffsetY : Float
  layoutScale : Float

def withContentRect (layout : Trellis.ComputedLayout) (draw : Float → Float → Afferent.CanvasM Unit) : Afferent.CanvasM Unit := do
  let rect := layout.contentRect
  Afferent.CanvasM.save
  Afferent.CanvasM.setBaseTransform (Transform.translate rect.x rect.y)
  Afferent.CanvasM.resetTransform
  Afferent.CanvasM.clip (Afferent.Rect.mk' 0 0 rect.width rect.height)
  draw rect.width rect.height
  Afferent.CanvasM.restore

end Demos
