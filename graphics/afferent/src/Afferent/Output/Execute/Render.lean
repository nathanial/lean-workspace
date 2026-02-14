/-
  Afferent Widget Backend Arbor Rendering
-/
import Afferent.Output.Canvas
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer
import Afferent.UI.Arbor
import Afferent.Output.Execute.Interpreter

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

private structure PreparedRender where
  measuredWidget : Afferent.Arbor.Widget
  layouts : Trellis.LayoutResult
  offsetX : Float := 0.0
  offsetY : Float := 0.0

structure ArborRenderStats where
  batch : BatchStats := {}
  timeCollectMs : Float := 0.0
  timeExecuteMs : Float := 0.0
  timeCustomMs : Float := 0.0
deriving Repr, Inhabited

private def prepareRender (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM PreparedRender := do
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

/-- Render an already measured Arbor widget tree using a precomputed layout result.
    This avoids redundant measure/layout passes when a caller already has layout data
    (for example: event dispatch and rendering in the same frame). -/
def renderMeasuredArborWidget (reg : FontRegistry) (measuredWidget : Afferent.Arbor.Widget)
    (layouts : Trellis.LayoutResult) (offsetX : Float := 0.0) (offsetY : Float := 0.0) : CanvasM Unit := do
  let commands ← collectCommands measuredWidget layouts
  executeWithOffset reg commands offsetX offsetY

/-- Render an Arbor widget tree using CanvasM.
    This is the single entry point for rendering Arbor widgets with Afferent's Metal backend. -/
def renderArborWidget (reg : FontRegistry) (widget : Afferent.Arbor.Widget)
    (availWidth availHeight : Float) : CanvasM ArborRenderStats := do
  let prepared ← prepareRender reg widget availWidth availHeight
  let (commands, timeCollectMs) ←
    collectCommandsWithStats prepared.measuredWidget prepared.layouts
  let (batchStats, timeExecuteMs) ←
    executeWithOffsetAndStats reg commands prepared.offsetX prepared.offsetY
  pure {
    batch := batchStats
    timeCollectMs
    timeExecuteMs
    timeCustomMs := 0.0
  }

end Afferent.Widget
