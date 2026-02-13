/-
  Afferent Render Plan Packets
  Backend-ready packet IR produced from render streams.
-/
import Afferent.UI.Arbor
import Afferent.Render.Stream
import Afferent.Render.Sink.Batches

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

/-- Planned packet to execute at the sink boundary. -/
inductive DrawPacket where
  | fillRectBatch (entries : Array RectBatchEntry)
  | strokeRectBatch (entries : Array StrokeRectBatchEntry) (lineWidth : Float)
  | fillCircleBatch (entries : Array CircleBatchEntry)
  | strokeCircleBatch (entries : Array StrokeCircleBatchEntry) (lineWidth : Float)
  | command (cmd : RenderCommand)
  deriving Repr

/-- Per-stage trace record for the stream pipeline. -/
structure StageTrace where
  name : String
  inputCount : Nat
  outputCount : Nat
  elapsedMs : Float
  deriving Repr, Inhabited

/-- Execution trace for one frame through the render stream pipeline. -/
structure RenderTrace where
  frameId : Nat := 0
  normalizedEvents : Nat := 0
  coalescedCommands : Nat := 0
  packets : Nat := 0
  stages : Array StageTrace := #[]
  deriving Repr, Inhabited

end Afferent.Widget
