/-
  Tracer.Core.TraceContext - Immutable trace context for propagation

  Contains the trace ID, span ID, and flags needed to propagate
  trace context across service boundaries.
-/

import Tracer.Core.TraceId
import Tracer.Core.SpanId
import Tracer.Core.TraceFlags

namespace Tracer

/-- Immutable trace context for propagation -/
structure TraceContext where
  /-- Identifies the entire trace -/
  traceId : TraceId
  /-- Identifies the current span -/
  spanId : SpanId
  /-- Trace flags (sampling decision) -/
  flags : TraceFlags
  /-- Vendor-specific trace state (key-value pairs) -/
  traceState : List (String × String) := []
  deriving Repr, BEq, Inhabited

namespace TraceContext

/-- Check if this context has valid IDs -/
def isValid (ctx : TraceContext) : Bool :=
  ctx.traceId.isValid && ctx.spanId.isValid

/-- Check if sampling is enabled -/
def isSampled (ctx : TraceContext) : Bool :=
  ctx.flags.isSampled

/-- Create a new root context with random IDs -/
def createRoot (sampled : Bool := true) : IO TraceContext := do
  let traceId ← TraceId.generate
  let spanId ← SpanId.generate
  let flags := if sampled then TraceFlags.sampled else TraceFlags.notSampled
  pure { traceId, spanId, flags }

/-- Create a child context (new span ID, same trace ID) -/
def createChild (parent : TraceContext) : IO TraceContext := do
  let spanId ← SpanId.generate
  pure { parent with spanId }

/-- Create a child context with a specific span ID (for testing) -/
def createChildWith (parent : TraceContext) (spanId : SpanId) : TraceContext :=
  { parent with spanId }

/-- Update the trace state -/
def withTraceState (ctx : TraceContext) (state : List (String × String)) : TraceContext :=
  { ctx with traceState := state }

/-- Add an entry to the trace state -/
def addTraceState (ctx : TraceContext) (key : String) (value : String) : TraceContext :=
  { ctx with traceState := (key, value) :: ctx.traceState }

/-- Set the sampled flag -/
def setSampled (ctx : TraceContext) (sampled : Bool) : TraceContext :=
  { ctx with flags := ctx.flags.setSampled sampled }

end TraceContext
end Tracer
