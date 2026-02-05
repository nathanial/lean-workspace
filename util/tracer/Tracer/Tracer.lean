/-
  Tracer.Tracer - Main tracer API

  Provides span creation, context management, and export functionality.
-/

import Tracer.Core.Span
import Tracer.Config

namespace Tracer

/-- Mutable state for an in-progress span -/
structure SpanBuilder where
  /-- Span name -/
  name : String
  /-- Trace context -/
  context : TraceContext
  /-- Parent span ID -/
  parentSpanId : Option SpanId
  /-- Span kind -/
  kind : SpanKind
  /-- Start time -/
  startTime : Nat
  /-- Accumulated attributes -/
  attributesRef : IO.Ref (Array Attribute)
  /-- Accumulated events -/
  eventsRef : IO.Ref (Array SpanEvent)
  /-- Status -/
  statusRef : IO.Ref SpanStatus

/-- Active tracer instance -/
structure Tracer where
  /-- Configuration -/
  config : TracerConfig
  /-- Pending spans buffer for batching -/
  pendingSpans : IO.Ref (Array Span)

namespace Tracer

/-- Create a new tracer -/
def create (config : TracerConfig) : IO Tracer := do
  let pendingSpans ← IO.mkRef #[]
  pure { config, pendingSpans }

/-- Export pending spans to all exporters -/
def flush (tracer : Tracer) : IO Unit := do
  let spans ← tracer.pendingSpans.modifyGet fun s => (#[], s)
  if spans.isEmpty then return ()
  for exporter in tracer.config.exporters do
    exporter.exportSpans spans

/-- Shutdown tracer and flush remaining spans -/
def shutdown (tracer : Tracer) : IO Unit := do
  tracer.flush
  for exporter in tracer.config.exporters do
    exporter.shutdown

/-- Record a completed span -/
private def recordSpan (tracer : Tracer) (span : Span) : IO Unit := do
  tracer.pendingSpans.modify (·.push span)
  -- Auto-flush if batch size reached
  let pending ← tracer.pendingSpans.get
  if pending.size >= tracer.config.batchSize then
    tracer.flush

/-- Start a new span builder -/
private def startSpanBuilder (tracer : Tracer) (ctx : TraceContext) (name : String)
    (parentSpanId : Option SpanId) (kind : SpanKind) : IO SpanBuilder := do
  let startTime ← IO.monoNanosNow
  let attributesRef ← IO.mkRef tracer.config.resourceAttributes
  let eventsRef ← IO.mkRef #[]
  let statusRef ← IO.mkRef SpanStatus.unset
  pure {
    name, context := ctx, parentSpanId, kind, startTime,
    attributesRef, eventsRef, statusRef
  }

/-- Complete a span builder and record it -/
private def finishSpanBuilder (tracer : Tracer) (builder : SpanBuilder) : IO Span := do
  let endTime ← IO.monoNanosNow
  let attributes ← builder.attributesRef.get
  let events ← builder.eventsRef.get
  let status ← builder.statusRef.get
  let span : Span := {
    name := builder.name
    context := builder.context
    parentSpanId := builder.parentSpanId
    kind := builder.kind
    startTime := builder.startTime
    endTime := endTime
    status := status
    attributes := attributes.toSubarray.toArray  -- Limit to maxAttributes if needed
    events := events.toSubarray.toArray  -- Limit to maxEvents if needed
  }
  tracer.recordSpan span
  pure span

/-- Create a span, run action, complete span on exit.
    Returns the result of the action and the child context used. -/
def withSpan (tracer : Tracer) (parentCtx : TraceContext) (name : String)
    (kind : SpanKind := .internal)
    (action : SpanBuilder → TraceContext → IO α) : IO α := do
  -- Check sampling
  let shouldSample ← tracer.config.sampler.shouldSample parentCtx
  if !shouldSample && !parentCtx.isSampled then
    -- Create a dummy context for non-sampled spans
    let childCtx ← TraceContext.createChild parentCtx
    let dummyBuilder : SpanBuilder := {
      name, context := childCtx, parentSpanId := some parentCtx.spanId, kind,
      startTime := 0,
      attributesRef := ← IO.mkRef #[],
      eventsRef := ← IO.mkRef #[],
      statusRef := ← IO.mkRef .unset
    }
    action dummyBuilder childCtx
  else
    -- Create child context with new span ID
    let childCtx ← TraceContext.createChild parentCtx
    let builder ← tracer.startSpanBuilder childCtx name (some parentCtx.spanId) kind
    try
      let result ← action builder childCtx
      let _ ← tracer.finishSpanBuilder builder
      pure result
    catch e =>
      -- Record error status
      builder.statusRef.set (.error (toString e))
      let _ ← tracer.finishSpanBuilder builder
      throw e

/-- Simplified withSpan that doesn't expose the builder -/
def withSpan' (tracer : Tracer) (parentCtx : TraceContext) (name : String)
    (kind : SpanKind := .internal)
    (action : TraceContext → IO α) : IO α :=
  tracer.withSpan parentCtx name kind fun _ ctx => action ctx

/-- Start a new root span (creates new trace) -/
def startRootSpan (tracer : Tracer) (name : String)
    (kind : SpanKind := .internal) : IO (SpanBuilder × TraceContext) := do
  let ctx ← TraceContext.createRoot
  let shouldSample ← tracer.config.sampler.shouldSample ctx
  let ctx := ctx.setSampled shouldSample
  let builder ← tracer.startSpanBuilder ctx name none kind
  pure (builder, ctx)

/-- Complete a root span -/
def finishRootSpan (tracer : Tracer) (builder : SpanBuilder) : IO Span :=
  tracer.finishSpanBuilder builder

/-- Add an attribute to a span builder -/
def addAttribute (builder : SpanBuilder) (attr : Attribute) : IO Unit :=
  builder.attributesRef.modify (·.push attr)

/-- Add multiple attributes to a span builder -/
def addAttributes (builder : SpanBuilder) (attrs : Array Attribute) : IO Unit :=
  builder.attributesRef.modify (· ++ attrs)

/-- Add an event to a span builder -/
def addEvent (builder : SpanBuilder) (name : String)
    (attrs : Array Attribute := #[]) : IO Unit := do
  let timestamp ← IO.monoNanosNow
  builder.eventsRef.modify (·.push { name, timestamp, attributes := attrs })

/-- Set the span status -/
def setStatus (builder : SpanBuilder) (status : SpanStatus) : IO Unit :=
  builder.statusRef.set status

/-- Set the span status to OK -/
def setOk (builder : SpanBuilder) : IO Unit :=
  builder.statusRef.set .ok

/-- Set the span status to error -/
def setError (builder : SpanBuilder) (message : String) : IO Unit :=
  builder.statusRef.set (.error message)

end Tracer

/-- RAII-style resource management for tracer -/
def withTracer (config : TracerConfig) (action : Tracer → IO α) : IO α := do
  let tracer ← Tracer.create config
  try
    let result ← action tracer
    tracer.shutdown
    pure result
  catch e =>
    tracer.shutdown
    throw e

end Tracer
