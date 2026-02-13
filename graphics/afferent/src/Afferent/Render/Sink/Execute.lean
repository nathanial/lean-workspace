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
  | .command cmd =>
    executeCommand reg cmd
  let t1 ← IO.monoNanosNow
  pure (t1 - t0)

end Afferent.Widget
