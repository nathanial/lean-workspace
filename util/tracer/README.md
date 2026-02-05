# Tracer

Distributed tracing library for Lean 4 with W3C Trace Context support.

## Overview

Tracer provides span management, context propagation, and export functionality for observability. It implements the [W3C Trace Context](https://www.w3.org/TR/trace-context/) specification for interoperability with other tracing systems.

## Installation

Add to your `lakefile.lean`:

```lean
require tracer from git "https://github.com/nathanial/tracer" @ "v0.0.1"
```

## Quick Start

```lean
import Tracer

def main : IO Unit := do
  -- Create a tracer with console output
  let config := TracerConfig.default "my-service"
    |>.withExporter Export.Console.exporter

  withTracer config fun tracer => do
    -- Create root context
    let ctx ← TraceContext.createRoot

    -- Create spans
    tracer.withSpan' ctx "handle-request" .server fun childCtx => do
      -- Nested spans become children
      tracer.withSpan' childCtx "db.query" .client fun _ => do
        -- ... perform database query
        pure ()
```

## Core Types

### TraceId

128-bit trace identifier (2x UInt64):

```lean
structure TraceId where
  high : UInt64
  low : UInt64

TraceId.generate : IO TraceId           -- Random ID
TraceId.fromHex : String → Option TraceId
TraceId.toHex : TraceId → String        -- 32-char lowercase hex
```

### SpanId

64-bit span identifier:

```lean
structure SpanId where
  value : UInt64

SpanId.generate : IO SpanId
SpanId.fromHex : String → Option SpanId
SpanId.toHex : SpanId → String          -- 16-char lowercase hex
```

### TraceContext

Immutable context for propagation:

```lean
structure TraceContext where
  traceId : TraceId
  spanId : SpanId
  flags : TraceFlags
  traceState : List (String × String)

TraceContext.createRoot : IO TraceContext
TraceContext.createChild : TraceContext → IO TraceContext
```

### Span

Completed span with timing and metadata:

```lean
structure Span where
  name : String
  context : TraceContext
  parentSpanId : Option SpanId
  kind : SpanKind           -- Internal, Server, Client, Producer, Consumer
  startTime : Nat           -- Nanoseconds (IO.monoNanosNow)
  endTime : Nat
  status : SpanStatus       -- Unset, Ok, Error
  attributes : Array Attribute
  events : Array SpanEvent
```

## W3C Trace Context

Parse and format `traceparent` headers:

```lean
-- Header format: "00-{trace-id}-{span-id}-{flags}"
W3C.parseTraceparent : String → Option TraceContext
W3C.formatTraceparent : TraceContext → String

-- Extract from HTTP headers
W3C.extractContext : (String → Option String) → Option TraceContext

-- Inject into outgoing requests
W3C.injectHeaders : TraceContext → List (String × String)
```

## Tracer API

```lean
-- Create tracer
Tracer.create : TracerConfig → IO Tracer

-- Create spans (recommended)
Tracer.withSpan' : Tracer → TraceContext → String → SpanKind
                 → (TraceContext → IO α) → IO α

-- Advanced: with span builder access
Tracer.withSpan : Tracer → TraceContext → String → SpanKind
                → (SpanBuilder → TraceContext → IO α) → IO α

-- Flush pending spans to exporters
Tracer.flush : Tracer → IO Unit

-- Shutdown (flush + shutdown exporters)
Tracer.shutdown : Tracer → IO Unit

-- RAII-style resource management
withTracer : TracerConfig → (Tracer → IO α) → IO α
```

## Sampling

Control which traces are recorded:

```lean
Sampler.alwaysOn           -- Sample all traces
Sampler.alwaysOff          -- Sample none
Sampler.probability 0.1    -- 10% sampling
Sampler.parentBased root   -- Inherit from parent, use root for new traces
Sampler.rateLimited 100    -- 100 traces per second
```

## Configuration

```lean
TracerConfig.default "service-name"
  |>.withSampler Sampler.alwaysOn
  |>.withExporter Export.Console.exporter
  |>.withServiceVersion "1.0.0"
  |>.withEnvironment "production"
  |>.withResourceAttribute (.string "host.name" "server-1")
  |>.withBatchSize 512
```

## Export

### Console Exporter (Development)

Pretty-prints spans to stderr with ANSI colors:

```lean
Export.Console.exporter : Exporter
```

Output format:
```
[SPAN] handle-request (45.2ms) OK
  trace=0af7651916cd43dd8448eb211c80319c span=b7ad6b7169203331
  kind=server attributes=2 events=0
```

## Integration Patterns

### With Citadel (HTTP Server)

```lean
-- Extract trace context from incoming request
let parentCtx := W3C.extractContext (req.header ·)
let ctx ← match parentCtx with
  | some parent => TraceContext.createChild parent
  | none => TraceContext.createRoot

tracer.withSpan' ctx "handle-request" .server fun spanCtx => do
  -- handle request
```

### With Wisp (HTTP Client)

```lean
-- Inject trace headers into outgoing request
let headers := W3C.injectHeaders ctx
let req := Wisp.Request.get url
  |>.withHeader (headers[0]!.1) (headers[0]!.2)
```

### With Chronicle (Logging)

```lean
-- Add trace correlation to logs
logger.logWithContext .info "Processing" [
  ("trace_id", ctx.traceId.toHex),
  ("span_id", ctx.spanId.toHex)
]
```

## Build Commands

```bash
lake build              # Build library
lake test               # Run tests
```

## Dependencies

- **crucible** - Test framework

## Future Work

- OTLP exporter (OpenTelemetry Protocol)
- Zipkin exporter
- Citadel middleware integration
- Wisp request helper integration
- Loom ActionM integration
- Chronicle log correlation integration

## License

MIT License
