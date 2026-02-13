/-
  Afferent Render Arbor Integration
-/
import Afferent.Output.Canvas
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Render.Plan.Pipeline

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

private structure PreparedRender where
  measuredWidget : Afferent.Arbor.Widget
  layouts : Trellis.LayoutResult
  offsetX : Float := 0.0
  offsetY : Float := 0.0

private structure RenderOptions where
  centered : Bool := false

structure ArborRenderStats where
  batch : BatchStats := {}
  timeCollectMs : Float := 0.0
  timeExecuteMs : Float := 0.0
  timeCustomMs : Float := 0.0
deriving Repr, Inhabited

/-- Stream-only renderer: custom CanvasM draw hooks are disabled. -/
partial def renderCustomWidgets (_w : Afferent.Arbor.Widget) (_layouts : Trellis.LayoutResult) : CanvasM Unit := do
  pure ()

private def prepareRender (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) (centered : Bool) : CanvasM PreparedRender := do
  if centered then
    let (intrinsicWidth, intrinsicHeight) ← runWithFonts reg (Afferent.Arbor.intrinsicSize widget)
    let measureResult ← runWithFonts reg (Afferent.Arbor.measureWidget widget intrinsicWidth intrinsicHeight)
    let layouts := Trellis.layout measureResult.node intrinsicWidth intrinsicHeight
    let offsetX := (availWidth - intrinsicWidth) / 2
    let offsetY := (availHeight - intrinsicHeight) / 2
    pure {
      measuredWidget := measureResult.widget
      layouts
      offsetX
      offsetY
    }
  else
    let measureResult ← runWithFonts reg (Afferent.Arbor.measureWidget widget availWidth availHeight)
    let layouts := Trellis.layout measureResult.node availWidth availHeight
    pure {
      measuredWidget := measureResult.widget
      layouts
    }

private def emitMeasuredCommands
    (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult)
    (offsetX offsetY : Float)
    (emit : RenderCommand → CanvasM Unit) : CanvasM Unit := do
  let hasOffset := offsetX != 0.0 || offsetY != 0.0
  if hasOffset then
    emit (.pushTranslate offsetX offsetY)
  Afferent.Arbor.collectCommandsFoldM measuredWidget layouts emit
  if hasOffset then
    emit .popTransform

private def measureCollectMs
    (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) : CanvasM Float := do
  let t0 ← IO.monoNanosNow
  Afferent.Arbor.collectCommandsFoldM measuredWidget layouts (fun _ => pure ())
  let t1 ← IO.monoNanosNow
  pure ((t1 - t0).toFloat / 1000000.0)

private def executeMeasuredWithStats (reg : FontRegistry)
    (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult)
    (offsetX offsetY : Float) : CanvasM (BatchStats × Float) := do
  let t0 ← IO.monoNanosNow
  let batchStats ← executeCommandProducerWithStats reg
    (emitMeasuredCommands measuredWidget layouts offsetX offsetY)
  let t1 ← IO.monoNanosNow
  pure (batchStats, (t1 - t0).toFloat / 1000000.0)

/-- Render an already measured Arbor widget tree using a precomputed layout result.
    This avoids redundant measure/layout passes when a caller already has layout data
    (for example: event dispatch and rendering in the same frame). -/
def renderMeasuredArborWidget (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  executeCommandProducer reg (emitMeasuredCommands measuredWidget layouts offsetX offsetY)

/-- Render an already measured Arbor widget tree.
    Custom draw hooks are intentionally ignored in the stream-only renderer path. -/
def renderMeasuredArborWidgetWithCustom (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  renderMeasuredArborWidget reg measuredWidget layouts offsetX offsetY

private def renderArborInternal (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) (opts : RenderOptions) : CanvasM Unit := do
  let prepared ← prepareRender reg widget availWidth availHeight opts.centered
  renderMeasuredArborWidget reg prepared.measuredWidget prepared.layouts
    prepared.offsetX prepared.offsetY

/-- Render an Arbor widget tree using CanvasM.
    This is the main entry point for rendering Arbor widgets with Afferent's Metal backend. -/
def renderArborWidget (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM Unit := do
  renderArborInternal reg widget availWidth availHeight {
    centered := false
  }

/-- Render an Arbor widget tree and return render statistics. -/
def renderArborWidgetWithCustomAndStats (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM ArborRenderStats := do
  let prepared ← prepareRender reg widget availWidth availHeight false
  let timeCollectMs ← measureCollectMs prepared.measuredWidget prepared.layouts
  let (batchStats, timeExecuteMs) ←
    executeMeasuredWithStats reg prepared.measuredWidget prepared.layouts prepared.offsetX prepared.offsetY
  pure {
    batch := batchStats
    timeCollectMs
    timeExecuteMs
    timeCustomMs := 0.0
  }

/-- Render an Arbor widget tree.
    Custom draw hooks are intentionally ignored in the stream-only renderer path. -/
def renderArborWidgetWithCustom (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM Unit := do
  renderArborWidget reg widget availWidth availHeight

/-- Render an Arbor widget tree centered on screen.
    Computes intrinsic size and offsets rendering to center the widget. -/
def renderArborWidgetCentered (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (screenWidth screenHeight : Float) : CanvasM Unit := do
  renderArborInternal reg widget screenWidth screenHeight {
    centered := true
  }

end Afferent.Widget
