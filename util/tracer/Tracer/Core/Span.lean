/-
  Tracer.Core.Span - Completed span structure

  Represents a completed unit of work with timing information,
  attributes, and events.
-/

import Tracer.Core.TraceContext
import Tracer.Core.SpanKind
import Tracer.Core.SpanStatus
import Tracer.Core.Attribute

namespace Tracer

/-- A timestamped event within a span -/
structure SpanEvent where
  /-- Event name -/
  name : String
  /-- Event timestamp in nanoseconds (from IO.monoNanosNow) -/
  timestamp : Nat
  /-- Event attributes -/
  attributes : Array Attribute := #[]
  deriving Repr, Inhabited

/-- A completed span ready for export -/
structure Span where
  /-- Operation name -/
  name : String
  /-- Trace context (contains trace ID, span ID, flags) -/
  context : TraceContext
  /-- Parent span ID (none for root spans) -/
  parentSpanId : Option SpanId := none
  /-- Kind of span (client, server, internal, etc.) -/
  kind : SpanKind := .internal
  /-- Start time in nanoseconds (from IO.monoNanosNow) -/
  startTime : Nat
  /-- End time in nanoseconds (from IO.monoNanosNow) -/
  endTime : Nat
  /-- Completion status -/
  status : SpanStatus := .unset
  /-- Span attributes -/
  attributes : Array Attribute := #[]
  /-- Timestamped events -/
  events : Array SpanEvent := #[]
  deriving Repr, Inhabited

namespace Span

/-- Duration in nanoseconds -/
def durationNanos (s : Span) : Nat :=
  s.endTime - s.startTime

/-- Duration in milliseconds -/
def durationMs (s : Span) : Float :=
  Float.ofNat s.durationNanos / 1_000_000.0

/-- Check if this is a root span -/
def isRoot (s : Span) : Bool :=
  s.parentSpanId.isNone

/-- Check if this span has an error status -/
def hasError (s : Span) : Bool :=
  s.status.isError

/-- Get the trace ID -/
def traceId (s : Span) : TraceId :=
  s.context.traceId

/-- Get the span ID -/
def spanId (s : Span) : SpanId :=
  s.context.spanId

end Span
end Tracer
