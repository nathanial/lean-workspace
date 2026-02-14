/-
  Afferent Widget Backend Execution Stats

  Lean-side batching helpers have been removed. This module now provides only
  the compatibility stats structure consumed by render entry points.
-/

namespace Afferent.Widget

/-- Statistics from command execution.
    Fields are kept for compatibility with prior batched metrics. -/
structure BatchStats where
  batchedCalls : Nat := 0
  individualCalls : Nat := 0
  totalCommands : Nat := 0
  rectsBatched : Nat := 0
  circlesBatched : Nat := 0
  strokeRectsBatched : Nat := 0
  strokeRectDirectRuns : Nat := 0
  strokeRectDirectRects : Nat := 0
  textsBatched : Nat := 0
  textFillCommands : Nat := 0
  textBatchFlushes : Nat := 0
  timeFlattenMs : Float := 0.0
  timeCoalesceMs : Float := 0.0
  timeBatchLoopMs : Float := 0.0
  timeDrawCallsMs : Float := 0.0
  timeTextPackMs : Float := 0.0
  timeTextFFIMs : Float := 0.0
  deriving Repr, Inhabited

end Afferent.Widget
