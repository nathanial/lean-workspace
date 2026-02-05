/-
  Tracer Tests
-/

import Crucible
import Tracer

open Crucible
open Tracer

/-- Check if a string contains a substring -/
def String.containsSubstr (s : String) (sub : String) : Bool :=
  (s.splitOn sub).length > 1

testSuite "Tracer"

-- TraceId tests
test "TraceId.generate produces valid ID" := do
  let id ← TraceId.generate
  shouldSatisfy id.isValid "TraceId should be valid"

test "TraceId.toHex produces 32-char string" := do
  let id ← TraceId.generate
  id.toHex.length ≡ 32

test "TraceId.fromHex round-trips" := do
  let id ← TraceId.generate
  let hex := id.toHex
  let parsed := TraceId.fromHex hex
  parsed ≡ some id

test "TraceId.fromHex rejects invalid input" := do
  TraceId.fromHex "too-short" ≡ none

test "TraceId.invalid is not valid" := do
  shouldSatisfy (!TraceId.invalid.isValid) "TraceId.invalid should not be valid"

-- SpanId tests
test "SpanId.generate produces valid ID" := do
  let id ← SpanId.generate
  shouldSatisfy id.isValid "SpanId should be valid"

test "SpanId.toHex produces 16-char string" := do
  let id ← SpanId.generate
  id.toHex.length ≡ 16

test "SpanId.fromHex round-trips" := do
  let id ← SpanId.generate
  let hex := id.toHex
  let parsed := SpanId.fromHex hex
  parsed ≡ some id

-- TraceFlags tests
test "TraceFlags.sampled has sampled flag set" := do
  shouldSatisfy TraceFlags.sampled.isSampled "sampled flag should be set"

test "TraceFlags.notSampled has sampled flag unset" := do
  shouldSatisfy (!TraceFlags.notSampled.isSampled) "sampled flag should be unset"

test "TraceFlags.toHex produces correct hex" := do
  TraceFlags.sampled.toHex ≡ "01"
  TraceFlags.notSampled.toHex ≡ "00"

test "TraceFlags.fromHex round-trips" := do
  let flags := TraceFlags.sampled
  let hex := flags.toHex
  let parsed := TraceFlags.fromHex hex
  parsed ≡ some flags

-- TraceContext tests
test "TraceContext.createRoot creates valid context" := do
  let ctx ← TraceContext.createRoot
  shouldSatisfy ctx.isValid "context should be valid"
  shouldSatisfy ctx.isSampled "context should be sampled"

test "TraceContext.createChild preserves trace ID" := do
  let parent ← TraceContext.createRoot
  let child ← TraceContext.createChild parent
  child.traceId ≡ parent.traceId

test "TraceContext.createChild creates new span ID" := do
  let parent ← TraceContext.createRoot
  let child ← TraceContext.createChild parent
  shouldSatisfy (child.spanId != parent.spanId) "child should have different span ID"

-- W3C Trace Context tests
test "W3C.parseTraceparent parses valid header" := do
  let header := "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
  match W3C.parseTraceparent header with
  | some ctx =>
    ctx.traceId.toHex ≡ "0af7651916cd43dd8448eb211c80319c"
    ctx.spanId.toHex ≡ "b7ad6b7169203331"
    shouldSatisfy ctx.flags.isSampled "flags should indicate sampled"
  | none => throw <| IO.userError "expected Some but got None"

test "W3C.parseTraceparent rejects invalid version" := do
  let header := "01-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
  W3C.parseTraceparent header ≡ none

test "W3C.parseTraceparent rejects all-zero trace ID" := do
  let header := "00-00000000000000000000000000000000-b7ad6b7169203331-01"
  W3C.parseTraceparent header ≡ none

test "W3C.formatTraceparent round-trips" := do
  let ctx ← TraceContext.createRoot
  let header := W3C.formatTraceparent ctx
  match W3C.parseTraceparent header with
  | some parsed =>
    parsed.traceId ≡ ctx.traceId
    parsed.spanId ≡ ctx.spanId
  | none => throw <| IO.userError "expected Some but got None"

test "W3C.parseTracestate parses key-value pairs" := do
  let header := "vendor1=value1,vendor2=value2"
  let state := W3C.parseTracestate header
  state.length ≡ 2

test "W3C.extractContext works with header lookup" := do
  let headers := [
    ("traceparent", "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"),
    ("tracestate", "vendor=value")
  ]
  let getHeader := fun name => headers.lookup name
  match W3C.extractContext getHeader with
  | some ctx => ctx.traceState.length ≡ 1
  | none => throw <| IO.userError "expected Some but got None"

-- Attribute tests
test "Attribute.string creates string attribute" := do
  let attr := Attribute.string "key" "value"
  attr.key ≡ "key"

test "Attributes.httpMethod creates standard attribute" := do
  let attr := Attributes.httpMethod "GET"
  attr.key ≡ "http.method"

-- SpanStatus tests
test "SpanStatus.isError returns true for errors" := do
  shouldSatisfy (SpanStatus.error "test").isError "error should be isError"
  shouldSatisfy (!SpanStatus.ok.isError) "ok should not be isError"

-- Sampler tests
test "Sampler.alwaysOn always samples" := do
  let sampler := Sampler.alwaysOn
  let ctx ← TraceContext.createRoot
  let result ← sampler.shouldSample ctx
  shouldSatisfy result "alwaysOn should sample"

test "Sampler.alwaysOff never samples" := do
  let sampler := Sampler.alwaysOff
  let ctx ← TraceContext.createRoot
  let result ← sampler.shouldSample ctx
  shouldSatisfy (!result) "alwaysOff should not sample"

-- Tracer tests
test "Tracer.create creates valid tracer" := do
  let config := TracerConfig.default "test-service"
  let tracer ← Tracer.create config
  tracer.config.serviceName ≡ "test-service"

test "Tracer.withSpan creates child context" := do
  let config := TracerConfig.default "test-service"
  let tracer ← Tracer.create config
  let parentCtx ← TraceContext.createRoot

  let childSpanId ← tracer.withSpan' parentCtx "test-span" .internal fun childCtx => do
    pure childCtx.spanId

  shouldSatisfy (childSpanId != parentCtx.spanId) "child should have different span ID"

test "Tracer.withSpan records span" := do
  let config := TracerConfig.default "test-service"
  let tracer ← Tracer.create config
  let parentCtx ← TraceContext.createRoot

  let _ ← tracer.withSpan' parentCtx "test-span" .internal fun _ => pure ()

  let pending ← tracer.pendingSpans.get
  pending.size ≡ 1

test "Tracer.withSpan preserves trace ID" := do
  let config := TracerConfig.default "test-service"
  let tracer ← Tracer.create config
  let parentCtx ← TraceContext.createRoot

  let childTraceId ← tracer.withSpan' parentCtx "test-span" .internal fun childCtx => do
    pure childCtx.traceId

  childTraceId ≡ parentCtx.traceId

-- Console exporter tests
test "Console.formatSpan produces output" := do
  let ctx ← TraceContext.createRoot
  let span : Span := {
    name := "test-span"
    context := ctx
    kind := .server
    startTime := 0
    endTime := 1_000_000  -- 1ms
  }
  let output := Export.Console.formatSpan span
  shouldSatisfy (output.containsSubstr "test-span") "output should contain span name"



-- Main entry point
def main : IO UInt32 := do
  IO.println "Tracer Distributed Tracing Library Tests"
  IO.println "========================================="
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result != 0 then
    IO.println "Some tests failed!"
    return 1
  else
    IO.println "All tests passed!"
    return 0
