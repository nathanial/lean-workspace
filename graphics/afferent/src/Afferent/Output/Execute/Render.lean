/-
  Afferent Widget Backend Arbor Rendering
-/
import Afferent.Output.Canvas
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Output.Execute.Batched

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
  renderCustom : Bool := false

structure ArborRenderStats where
  batch : BatchStats := {}
  cacheHits : Nat := 0
  cacheMisses : Nat := 0
  timeCollectMs : Float := 0.0
  timeExecuteMs : Float := 0.0
  timeCustomMs : Float := 0.0
deriving Repr, Inhabited

partial def renderCustomWidgets (w : Afferent.Arbor.Widget) (layouts : Trellis.LayoutResult) : CanvasM Unit := do
  match layouts.get w.id with
  | none => pure ()
  | some layout =>
      match w with
      | .custom _ _ _ spec _ =>
          match spec.draw with
          | some draw => draw layout
          | none => pure ()
      | .flex _ _ _ _ children _
      | .grid _ _ _ _ children _ =>
          for child in children do
            renderCustomWidgets child layouts
      | .scroll _ _ _ scrollState _ _ _ child _ =>
          let contentRect := layout.contentRect
          let clipRect : Rect :=
            ⟨⟨contentRect.x, contentRect.y⟩, ⟨contentRect.width, contentRect.height⟩⟩
          CanvasM.clip clipRect
          CanvasM.save
          CanvasM.translate (-scrollState.offsetX) (-scrollState.offsetY)
          renderCustomWidgets child layouts
          CanvasM.restore
          CanvasM.popClip
      | _ => pure ()

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

private def renderMeasuredViaSinkWithStats (reg : FontRegistry)
    (measuredWidget : Afferent.Arbor.Widget) (layouts : Trellis.LayoutResult)
    (offsetX offsetY : Float := 0.0) : CanvasM ArborRenderStats := do
  let canvas ← CanvasM.getCanvas
  let sink ← BatchCommandSink.new reg canvas
  if offsetX != 0.0 || offsetY != 0.0 then
    sink.emit .save
    sink.emit (.pushTranslate offsetX offsetY)

  let t0 ← IO.monoNanosNow
  let (hits, misses) ←
    Afferent.Arbor.collectCommandsCachedIntoWithSinkAndStats
      canvas.drawRuntime.renderCache measuredWidget layouts sink.toRenderSink
  if offsetX != 0.0 || offsetY != 0.0 then
    sink.emit .popTransform
    sink.emit .restore
  let (batchStats, canvas', executeNs) ← sink.finish
  let t1 ← IO.monoNanosNow
  CanvasM.setCanvas canvas'

  let totalMs := (t1 - t0).toFloat / 1000000.0
  let timeExecuteMs := executeNs.toFloat / 1000000.0
  let rawCollectMs := totalMs - timeExecuteMs
  let timeCollectMs := if rawCollectMs > 0.0 then rawCollectMs else 0.0

  pure {
    batch := batchStats
    cacheHits := hits
    cacheMisses := misses
    timeCollectMs
    timeExecuteMs
    timeCustomMs := 0.0
  }

private def renderCustomWithOffset (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult)
    (offsetX offsetY : Float) : CanvasM Float := do
  let t0 ← IO.monoNanosNow
  if offsetX == 0.0 && offsetY == 0.0 then
    renderCustomWidgets measuredWidget layouts
  else
    CanvasM.save
    CanvasM.translate offsetX offsetY
    renderCustomWidgets measuredWidget layouts
    CanvasM.restore
  let t1 ← IO.monoNanosNow
  pure ((t1 - t0).toFloat / 1000000.0)

/-- Render an already measured Arbor widget tree using a precomputed layout result.
    This avoids redundant measure/layout passes when a caller already has layout data
    (for example: event dispatch and rendering in the same frame). -/
def renderMeasuredArborWidget (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  let _ ← renderMeasuredViaSinkWithStats reg measuredWidget layouts offsetX offsetY
  pure ()

/-- Render an already measured Arbor widget tree and run custom CanvasM draw hooks.
    Use this when the caller already computed measurement/layout and needs parity
    with `renderArborWidgetWithCustom` without recomputing layout. -/
def renderMeasuredArborWidgetWithCustom (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  let _ ← renderMeasuredViaSinkWithStats reg measuredWidget layouts offsetX offsetY
  if offsetX == 0.0 && offsetY == 0.0 then
    renderCustomWidgets measuredWidget layouts
  else
    CanvasM.save
    CanvasM.translate offsetX offsetY
    renderCustomWidgets measuredWidget layouts
    CanvasM.restore

/-- Render an already measured Arbor widget tree, run custom CanvasM draw hooks,
    and return render statistics without re-running measure/layout. -/
def renderMeasuredArborWidgetWithCustomAndStats (reg : FontRegistry)
    (measuredWidget : Afferent.Arbor.Widget) (layouts : Trellis.LayoutResult)
    (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM ArborRenderStats := do
  let renderStats ← renderMeasuredViaSinkWithStats reg measuredWidget layouts offsetX offsetY
  let timeCustomMs ← renderCustomWithOffset measuredWidget layouts offsetX offsetY
  pure { renderStats with timeCustomMs := timeCustomMs }

private def renderArborInternal (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) (opts : RenderOptions) : CanvasM Unit := do
  let prepared ← prepareRender reg widget availWidth availHeight opts.centered
  renderMeasuredArborWidget reg prepared.measuredWidget prepared.layouts
    prepared.offsetX prepared.offsetY
  if opts.renderCustom then
    if prepared.offsetX == 0.0 && prepared.offsetY == 0.0 then
      renderCustomWidgets prepared.measuredWidget prepared.layouts
    else
      CanvasM.save
      CanvasM.translate prepared.offsetX prepared.offsetY
      renderCustomWidgets prepared.measuredWidget prepared.layouts
      CanvasM.restore

/-- Render an Arbor widget tree using CanvasM with automatic render command caching.
    This is the main entry point for rendering Arbor widgets with Afferent's Metal backend. -/
def renderArborWidget (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM Unit := do
  renderArborInternal reg widget availWidth availHeight {
    centered := false
    renderCustom := false
  }

/-- Render an Arbor widget tree, run custom draw hooks, and return render statistics. -/
def renderArborWidgetWithCustomAndStats (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM ArborRenderStats := do
  let prepared ← prepareRender reg widget availWidth availHeight false
  renderMeasuredArborWidgetWithCustomAndStats reg
    prepared.measuredWidget prepared.layouts prepared.offsetX prepared.offsetY

/-- Render an Arbor widget tree and run any custom CanvasM draw hooks. -/
def renderArborWidgetWithCustom (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM Unit := do
  let _ ← renderArborWidgetWithCustomAndStats reg widget availWidth availHeight
  pure ()

/-- Render an Arbor widget tree centered on screen.
    Computes intrinsic size and offsets rendering to center the widget. -/
def renderArborWidgetCentered (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (screenWidth screenHeight : Float) : CanvasM Unit := do
  renderArborInternal reg widget screenWidth screenHeight {
    centered := true
    renderCustom := false
  }

end Afferent.Widget
