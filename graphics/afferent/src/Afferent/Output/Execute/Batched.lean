/-
  Afferent Widget Backend Command Execution (Sequential)

  Lean-side batching/coalescing has been removed. This module keeps the
  historical API surface (`executeCommandsBatched*`) for compatibility while
  executing commands strictly in-order via the interpreter.
-/
import Afferent.Output.Execute.Interpreter
import Afferent.Output.Execute.Batches

namespace Afferent.Widget

open Afferent
open Afferent.Arbor

/-- Execute a RenderCommand stream sequentially and return execution stats.

    Note: Lean-side batching/coalescing is intentionally disabled; all
    commands are interpreted in-order to preserve exact clip/transform/scroll
    semantics and avoid per-frame churn in Lean. -/
def executeCommandsBatchedWithStats (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM BatchStats := do
  let t0 ← IO.monoNanosNow
  for cmd in cmds do
    executeCommand reg cmd
  let t1 ← IO.monoNanosNow

  let totalMs := (t1 - t0).toFloat / 1000000.0
  pure {
    totalCommands := cmds.size
    individualCalls := cmds.size
    timeBatchLoopMs := totalMs
    timeDrawCallsMs := totalMs
  }

/-- Compatibility entry point.
    Executes commands sequentially (no Lean-side batching). -/
def executeCommandsBatched (reg : FontRegistry)
    (cmds : Array Afferent.Arbor.RenderCommand) : CanvasM Unit := do
  let _ ← executeCommandsBatchedWithStats reg cmds
  pure ()

end Afferent.Widget
