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
  renderCustom : Bool := false

structure ArborRenderStats where
  batch : BatchStats := {}
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

private def collectCommands (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) : CanvasM (Array Afferent.Arbor.RenderCommand) := do
  pure (Afferent.Arbor.collectCommands measuredWidget layouts)

private def collectCommandsWithStats (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) : CanvasM (Array Afferent.Arbor.RenderCommand × Float) := do
  let t0 ← IO.monoNanosNow
  let commands := Afferent.Arbor.collectCommands measuredWidget layouts
  let t1 ← IO.monoNanosNow
  pure (commands, (t1 - t0).toFloat / 1000000.0)

/-- Run an action under a temporary translation offset. -/
private def withOffset (offsetX offsetY : Float) (action : CanvasM α) : CanvasM α := do
  if offsetX == 0.0 && offsetY == 0.0 then
    action
  else
    CanvasM.save
    CanvasM.translate offsetX offsetY
    let result ← action
    CanvasM.restore
    pure result

private def executeWithOffset (reg : FontRegistry)
    (commands : Array Afferent.Arbor.RenderCommand)
    (offsetX offsetY : Float) : CanvasM Unit := do
  withOffset offsetX offsetY (executeCommandsBatched reg commands)

private def executeWithOffsetAndStats (reg : FontRegistry)
    (commands : Array Afferent.Arbor.RenderCommand)
    (offsetX offsetY : Float) : CanvasM (BatchStats × Float) := do
  let t0 ← IO.monoNanosNow
  let batchStats ← withOffset offsetX offsetY (executeCommandsBatchedWithStats reg commands)
  let t1 ← IO.monoNanosNow
  pure (batchStats, (t1 - t0).toFloat / 1000000.0)

private def renderCustomWithOffset (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult)
    (offsetX offsetY : Float) : CanvasM Float := do
  let t0 ← IO.monoNanosNow
  withOffset offsetX offsetY (renderCustomWidgets measuredWidget layouts)
  let t1 ← IO.monoNanosNow
  pure ((t1 - t0).toFloat / 1000000.0)

/-- Render an already measured Arbor widget tree using a precomputed layout result.
    This avoids redundant measure/layout passes when a caller already has layout data
    (for example: event dispatch and rendering in the same frame). -/
def renderMeasuredArborWidget (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  let commands ← collectCommands measuredWidget layouts
  executeWithOffset reg commands offsetX offsetY

/-- Render an already measured Arbor widget tree and run custom CanvasM draw hooks.
    Use this when the caller already computed measurement/layout and needs parity
    with `renderArborWidgetWithCustom` without recomputing layout. -/
def renderMeasuredArborWidgetWithCustom (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  renderMeasuredArborWidget reg measuredWidget layouts offsetX offsetY
  withOffset offsetX offsetY (renderCustomWidgets measuredWidget layouts)

private def renderArborInternal (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) (opts : RenderOptions) : CanvasM Unit := do
  let prepared ← prepareRender reg widget availWidth availHeight opts.centered
  renderMeasuredArborWidget reg prepared.measuredWidget prepared.layouts
    prepared.offsetX prepared.offsetY
  if opts.renderCustom then
    withOffset prepared.offsetX prepared.offsetY
      (renderCustomWidgets prepared.measuredWidget prepared.layouts)

/-- Render an Arbor widget tree using CanvasM.
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
  let (commands, timeCollectMs) ←
    collectCommandsWithStats prepared.measuredWidget prepared.layouts
  let (batchStats, timeExecuteMs) ←
    executeWithOffsetAndStats reg commands prepared.offsetX prepared.offsetY
  let timeCustomMs ←
    renderCustomWithOffset prepared.measuredWidget prepared.layouts prepared.offsetX prepared.offsetY
  pure {
    batch := batchStats
    timeCollectMs
    timeExecuteMs
    timeCustomMs
  }

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
