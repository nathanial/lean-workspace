# CLAUDE.md - tracer

## Overview

Distributed tracing library for Lean 4 with W3C Trace Context support. Provides span management, context propagation, and export functionality for observability.

## Build Commands

```bash
lake build           # Build library
lake test            # Run tests
```

## Architecture

### Core Types

- `TraceId` - 128-bit trace identifier (2x UInt64)
- `SpanId` - 64-bit span identifier
- `TraceFlags` - W3C trace flags (sampled bit)
- `TraceContext` - Immutable context for propagation (traceId + spanId + flags + traceState)
- `Span` - Completed span with timing, attributes, and events
- `SpanKind` - Internal, Server, Client, Producer, Consumer
- `SpanStatus` - Unset, Ok, Error
- `Attribute` - Key-value span metadata

### W3C Trace Context

- `W3C.parseTraceparent` - Parse `traceparent` header
- `W3C.formatTraceparent` - Format context as header
- `W3C.extractContext` - Extract from HTTP headers
- `W3C.injectHeaders` - Inject into outgoing requests

Header format: `00-{trace-id}-{span-id}-{flags}`

### Tracer API

```lean
-- Create tracer with config
let config := TracerConfig.default "my-service"
  |>.withExporter Export.Console.default
let tracer ← Tracer.create config

-- Create spans
let rootCtx ← TraceContext.createRoot
tracer.withSpan' rootCtx "operation" .server fun childCtx => do
  -- nested spans become children
  tracer.withSpan' childCtx "db.query" .client fun _ => do
    performQuery

-- Flush and shutdown
tracer.shutdown
```

### Sampling

- `Sampler.alwaysOn` - Sample all traces
- `Sampler.alwaysOff` - Sample none
- `Sampler.probability rate` - Probabilistic sampling
- `Sampler.parentBased root` - Inherit from parent
- `Sampler.rateLimited n` - N traces per second

### Export

- `Export.Console.exporter` - Pretty-print to stderr (development)

Future: OTLP, Zipkin exporters

### File Structure

```
Tracer/
├── Core/
│   ├── TraceId.lean       # 128-bit trace ID
│   ├── SpanId.lean        # 64-bit span ID
│   ├── TraceFlags.lean    # Sampling flags
│   ├── TraceContext.lean  # Context for propagation
│   ├── SpanKind.lean      # Span type enum
│   ├── SpanStatus.lean    # Span result status
│   ├── Attribute.lean     # Key-value attributes
│   └── Span.lean          # Completed span structure
├── W3C.lean               # W3C Trace Context parsing
├── Config.lean            # TracerConfig, Sampler, Exporter
├── Sampler.lean           # Sampling strategies
├── Tracer.lean            # Main tracer API
└── Export/
    └── Console.lean       # Console exporter
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

## Dependencies

- **crucible** - Test framework

## Future Work

- OTLP exporter (OpenTelemetry Protocol)
- Zipkin exporter
- Citadel middleware integration
- Wisp request helper integration
- Loom ActionM integration
- Chronicle log correlation integration
