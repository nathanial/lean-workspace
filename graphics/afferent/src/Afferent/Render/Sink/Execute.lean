/-
  Afferent Render Sink Execute
  Terminal execution boundary for planned draw packets.
-/
import Afferent.Output.Canvas
import Afferent.Graphics.Text.Font
import Afferent.UI.Arbor
import Afferent.Render.Plan.Packet
import Afferent.Render.Sink.Interpreter
import Afferent.Render.Sink.Batches

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

private def executeRenderCommandPacket (reg : FontRegistry) (packet : DrawPacket) : CanvasM Unit :=
  match packet with
  | .fillRect rect color cornerRadius =>
    executeCommand reg (.fillRect rect color cornerRadius)
  | .fillRectStyle rect style cornerRadius =>
    executeCommand reg (.fillRectStyle rect style cornerRadius)
  | .strokeRect rect color lineWidth cornerRadius =>
    executeCommand reg (.strokeRect rect color lineWidth cornerRadius)
  | .strokeRectPacked data count lineWidth =>
    executeCommand reg (.strokeRectBatch data count lineWidth)
  | .fillCircle center radius color =>
    executeCommand reg (.fillCircle center radius color)
  | .fillCirclePacked data count =>
    executeCommand reg (.fillCircleBatch data count)
  | .strokeCircle center radius color lineWidth =>
    executeCommand reg (.strokeCircle center radius color lineWidth)
  | .strokeLine p1 p2 color lineWidth =>
    executeCommand reg (.strokeLine p1 p2 color lineWidth)
  | .strokeLineBatch data count lineWidth =>
    executeCommand reg (.strokeLineBatch data count lineWidth)
  | .fillText text x y font color =>
    executeCommand reg (.fillText text x y font color)
  | .fillTextBlock text rect font color align valign =>
    executeCommand reg (.fillTextBlock text rect font color align valign)
  | .fillPolygon points color =>
    executeCommand reg (.fillPolygon points color)
  | .strokePolygon points color lineWidth =>
    executeCommand reg (.strokePolygon points color lineWidth)
  | .fillPath path color =>
    executeCommand reg (.fillPath path color)
  | .fillPathStyle path style =>
    executeCommand reg (.fillPathStyle path style)
  | .strokePath path color lineWidth =>
    executeCommand reg (.strokePath path color lineWidth)
  | .fillPolygonInstanced pathHash vertices indices instances centerX centerY =>
    executeCommand reg (.fillPolygonInstanced pathHash vertices indices instances centerX centerY)
  | .strokeArcInstanced instances segments =>
    executeCommand reg (.strokeArcInstanced instances segments)
  | .drawFragment fragmentHash primitiveType params instanceCount =>
    executeCommand reg (.drawFragment fragmentHash primitiveType params instanceCount)
  | .fillTessellatedBatch vertices indices vertexCount =>
    executeCommand reg (.fillTessellatedBatch vertices indices vertexCount)
  | .pushClip rect =>
    executeCommand reg (.pushClip rect)
  | .popClip =>
    executeCommand reg .popClip
  | .pushTranslate dx dy =>
    executeCommand reg (.pushTranslate dx dy)
  | .pushRotate angle =>
    executeCommand reg (.pushRotate angle)
  | .pushScale sx sy =>
    executeCommand reg (.pushScale sx sy)
  | .popTransform =>
    executeCommand reg .popTransform
  | .save =>
    executeCommand reg .save
  | .restore =>
    executeCommand reg .restore
  | .fillRectBatch _
  | .strokeRectBatch _ _
  | .fillCircleBatch _
  | .strokeCircleBatch _ _ =>
    pure ()

/-- Execute one planned draw packet.
    Returns elapsed time in nanoseconds for draw-call timing metrics. -/
def executeDrawPacket (reg : FontRegistry) (packet : DrawPacket) : CanvasM Nat := do
  let t0 ← IO.monoNanosNow
  match packet with
  | .fillRectBatch entries =>
    executeFillRectBatch entries
  | .strokeRectBatch entries lineWidth =>
    executeStrokeRectBatch entries lineWidth
  | .fillCircleBatch entries =>
    executeFillCircleBatch entries
  | .strokeCircleBatch entries lineWidth =>
    executeStrokeCircleBatch entries lineWidth
  | _ =>
    executeRenderCommandPacket reg packet
  let t1 ← IO.monoNanosNow
  pure (t1 - t0)

end Afferent.Widget
