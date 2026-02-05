# Tracer Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Tracer distributed tracing library.

---

## Feature Proposals

### [Priority: High] OTLP Exporter (OpenTelemetry Protocol)

**Description:** Implement an exporter that sends spans to OpenTelemetry-compatible backends using OTLP (OpenTelemetry Protocol) over HTTP/JSON or gRPC.

**Rationale:** OTLP is the industry standard for telemetry data export. Supporting it would enable integration with Jaeger, Tempo, Honeycomb, and other observability platforms that accept OTLP. This is essential for production use cases.

**Affected Files:**
- New file: `Tracer/Export/OTLP.lean`
- New file: `Tracer/Export/OTLP/Types.lean` (OTLP protobuf message types)

**Estimated Effort:** Large

**Dependencies:**
- Requires `wisp` (HTTP client) for HTTP/JSON transport
- Optionally `protolean` and `legate` for gRPC transport


### [Priority: High] Baggage Support (W3C Baggage Specification)

**Description:** Implement W3C Baggage specification for propagating key-value pairs across service boundaries alongside trace context.

**Rationale:** Baggage allows propagating arbitrary metadata (user IDs, feature flags, tenant IDs) across services without modifying business logic. This is a core OpenTelemetry feature.

**Affected Files:**
- New file: `Tracer/Baggage.lean`
- `Tracer/W3C.lean` (add `parseBaggage`, `formatBaggage` functions)

**Estimated Effort:** Medium

**Dependencies:** None


### [Priority: High] Citadel Middleware Integration

**Description:** Create a ready-to-use tracing middleware for the Citadel HTTP server that automatically creates spans for incoming requests.

**Rationale:** HTTP server tracing is the most common use case. Providing a drop-in middleware would significantly improve developer experience and ensure consistent span creation.

**Affected Files:**
- New file: `Tracer/Integration/Citadel.lean`

**Estimated Effort:** Medium

**Dependencies:** Requires `citadel` HTTP server library


### [Priority: Medium] Zipkin Exporter

**Description:** Implement an exporter that sends spans to Zipkin-compatible backends using Zipkin's JSON format.

**Rationale:** While OTLP is preferred, Zipkin remains popular and some organizations have existing Zipkin infrastructure. Supporting both formats maximizes compatibility.

**Affected Files:**
- New file: `Tracer/Export/Zipkin.lean`

**Estimated Effort:** Medium

**Dependencies:** Requires `wisp` HTTP client


### [Priority: Medium] Span Links Support

**Description:** Add support for span links, which connect spans that are causally related but not in a parent-child relationship.

**Rationale:** Span links are useful for batch processing, fan-out operations, and connecting multiple traces that originate from the same event. This is part of the OpenTelemetry specification.

**Affected Files:**
- `Tracer/Core/Span.lean` (add `links` field)
- New file: `Tracer/Core/Link.lean`
- `Tracer/Export/Console.lean` (display links)

**Estimated Effort:** Small

**Dependencies:** None


### [Priority: Medium] Wisp HTTP Client Integration

**Description:** Create helpers for automatically injecting trace context into outgoing HTTP requests made with Wisp.

**Rationale:** Client-side tracing is essential for distributed trace continuity. Providing helpers reduces boilerplate and ensures correct header propagation.

**Affected Files:**
- New file: `Tracer/Integration/Wisp.lean`

**Estimated Effort:** Small

**Dependencies:** Requires `wisp` HTTP client


### [Priority: Medium] Loom ActionM Integration

**Description:** Integrate tracing into Loom's ActionM monad with automatic span creation for controller actions.

**Rationale:** Loom is the primary web framework in the workspace. Native integration would make tracing "just work" for web applications.

**Affected Files:**
- New file: `Tracer/Integration/Loom.lean`

**Estimated Effort:** Medium

**Dependencies:** Requires `loom` web framework


### [Priority: Medium] Chronicle Log Correlation

**Description:** Provide helpers to inject trace context (trace ID, span ID) into Chronicle log entries for log correlation.

**Rationale:** Correlating logs with traces is essential for debugging. Users should be able to click from a log line to the associated trace in their observability platform.

**Affected Files:**
- New file: `Tracer/Integration/Chronicle.lean`

**Estimated Effort:** Small

**Dependencies:** Requires `chronicle` logging library


### [Priority: Medium] Async/Background Span Export

**Description:** Add support for asynchronous span export using a background thread/task to avoid blocking the main application.

**Rationale:** Synchronous export can add latency to request handling. Production systems should export spans asynchronously to minimize performance impact.

**Affected Files:**
- `Tracer/Tracer.lean` (add async export option)
- `Tracer/Config.lean` (add async config options)
- New file: `Tracer/Export/AsyncProcessor.lean`

**Estimated Effort:** Medium

**Dependencies:** Requires `conduit` for thread-safe queue


### [Priority: Medium] Span Processor Pipeline

**Description:** Implement a composable span processor pipeline that allows filtering, batching, and transforming spans before export.

**Rationale:** Production systems often need to filter out health check spans, sample certain endpoints differently, or enrich spans with additional metadata. A processor pipeline enables these use cases.

**Affected Files:**
- New file: `Tracer/Processor.lean`
- New file: `Tracer/Processor/Batch.lean`
- New file: `Tracer/Processor/Filter.lean`
- `Tracer/Config.lean` (add processor configuration)

**Estimated Effort:** Medium

**Dependencies:** None


### [Priority: Low] Metrics Bridge

**Description:** Add helpers to record span-derived metrics (request count, duration histograms) for integration with a future metrics library.

**Rationale:** Many observability systems derive metrics from traces (RED metrics: Rate, Errors, Duration). Preparing for this integration enables future unified observability.

**Affected Files:**
- New file: `Tracer/Metrics.lean`

**Estimated Effort:** Medium

**Dependencies:** Future metrics library


### [Priority: Low] gRPC Interceptor Support

**Description:** Create trace context propagation interceptors for the Legate gRPC library.

**Rationale:** gRPC services need trace context propagation just like HTTP services. Supporting Legate would enable full distributed tracing across gRPC microservices.

**Affected Files:**
- New file: `Tracer/Integration/Legate.lean`

**Estimated Effort:** Medium

**Dependencies:** Requires `legate` gRPC library


### [Priority: Low] TraceContext Monad Transformer

**Description:** Create a `TracerT` monad transformer that carries trace context implicitly, avoiding explicit context threading.

**Rationale:** Explicit context passing is verbose. A monad transformer would provide cleaner ergonomics similar to Haskell's `MonadTrace` pattern.

**Affected Files:**
- New file: `Tracer/TracerT.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Extract Duplicate Hex Conversion Code

**Current State:** `hexCharToNat` and `nibbleToHexChar` functions are duplicated across `TraceId.lean`, `SpanId.lean`, and `TraceFlags.lean` (lines 36-40, 44-48, 27-30, 44-50, 32-36, 48-51 respectively).

**Proposed Change:** Extract common hex conversion utilities to a shared module `Tracer/Core/Hex.lean` and reuse across all ID types.

**Benefits:** Reduced code duplication, single point of maintenance, smaller compiled output.

**Affected Files:**
- New file: `Tracer/Core/Hex.lean`
- `Tracer/Core/TraceId.lean`
- `Tracer/Core/SpanId.lean`
- `Tracer/Core/TraceFlags.lean`

**Estimated Effort:** Small


### [Priority: High] Add Type-Safe Attribute Builders

**Current State:** Attribute values are created using string keys which are error-prone. Semantic convention attributes exist in `Attributes` namespace but could be more extensive.

**Proposed Change:** Create a more comprehensive set of type-safe attribute builders following OpenTelemetry semantic conventions. Consider using compile-time key validation or a builder pattern.

**Benefits:** Reduced typos in attribute keys, better IDE autocomplete, conformance with OpenTelemetry standards.

**Affected Files:**
- `Tracer/Core/Attribute.lean`
- New file: `Tracer/Semantic/Http.lean`
- New file: `Tracer/Semantic/Database.lean`
- New file: `Tracer/Semantic/Messaging.lean`

**Estimated Effort:** Medium


### [Priority: Medium] Improve Sampler Error Handling

**Current State:** The `parentBased` sampler in `Tracer/Sampler.lean` (lines 33-40) has unclear logic for distinguishing root vs child spans.

**Proposed Change:** Clarify the logic by checking `parentSpanId` field rather than relying on `traceId.isValid` and `isSampled` flags. Add documentation explaining the sampling decision flow.

**Benefits:** More predictable sampling behavior, easier to debug sampling issues.

**Affected Files:**
- `Tracer/Sampler.lean`

**Estimated Effort:** Small


### [Priority: Medium] Add Resource Detection

**Current State:** Resource attributes must be manually configured in `TracerConfig`.

**Proposed Change:** Add automatic resource detection for common attributes like hostname, process ID, runtime version, and OS information.

**Benefits:** Less configuration required, more useful span metadata by default.

**Affected Files:**
- New file: `Tracer/Resource.lean`
- `Tracer/Config.lean`

**Estimated Effort:** Small


### [Priority: Medium] Enforce Max Attributes/Events Limits

**Current State:** `TracerConfig` has `maxAttributes` and `maxEvents` fields but they are not enforced. The comment in `Tracer/Tracer.lean` (lines 92-93) mentions "Limit to maxAttributes if needed" but no limiting is actually done.

**Proposed Change:** Actually enforce the limits by truncating attributes/events arrays when finishing spans.

**Benefits:** Prevents memory issues from runaway attribute/event accumulation, matches OpenTelemetry SDK behavior.

**Affected Files:**
- `Tracer/Tracer.lean` (lines 79-96)

**Estimated Effort:** Small


### [Priority: Medium] Add Hashable Instance for TraceId and SpanId

**Current State:** `TraceId` and `SpanId` only derive `BEq` and `Repr`.

**Proposed Change:** Add `Hashable` instances to enable use in `HashMap` and `HashSet` for efficient span lookup and deduplication.

**Benefits:** Enables efficient span indexing, useful for building span trees and parent-child relationships.

**Affected Files:**
- `Tracer/Core/TraceId.lean`
- `Tracer/Core/SpanId.lean`

**Estimated Effort:** Small


### [Priority: Low] Use Chronos for Timestamps

**Current State:** Timestamps use `IO.monoNanosNow` which gives monotonic nanoseconds. For export, wall clock time is often needed.

**Proposed Change:** Add integration with the `chronos` library to capture both monotonic (for duration) and wall clock (for absolute timestamp) times.

**Benefits:** Proper wall clock timestamps for span start/end times in exported data.

**Affected Files:**
- `Tracer/Core/Span.lean`
- `Tracer/Tracer.lean`
- `lakefile.lean` (add chronos dependency)

**Estimated Effort:** Small


### [Priority: Low] Optimize String Building in Hex Conversion

**Current State:** `toHex` functions build strings via repeated concatenation which is O(n^2).

**Proposed Change:** Use `String.mk` with a pre-allocated list or use a `StringBuilder` pattern for O(n) performance.

**Benefits:** Better performance for high-volume tracing scenarios.

**Affected Files:**
- `Tracer/Core/TraceId.lean` (lines 67-77)
- `Tracer/Core/SpanId.lean` (lines 50-59)

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: High] Add Missing floatArray Attribute Type

**Issue:** `AttributeValue` in `Tracer/Core/Attribute.lean` includes `stringArray` and `intArray` but is missing `floatArray` and `boolArray` which are part of the OpenTelemetry specification.

**Location:** `Tracer/Core/Attribute.lean`, lines 11-17

**Action Required:** Add `floatArray` and `boolArray` variants to `AttributeValue` and corresponding `toString` cases.

**Estimated Effort:** Small


### [Priority: Medium] Consolidate Span Duration Helpers

**Issue:** `Span` has `durationNanos` and `durationMs` but no `durationSeconds` for consistency. Also, `formatDuration` in Console exporter duplicates duration formatting logic.

**Location:**
- `Tracer/Core/Span.lean` (lines 49-55)
- `Tracer/Export/Console.lean` (lines 37-46)

**Action Required:** Add `durationSeconds` to `Span` and consider moving `formatDuration` to `Span` as a method or to a shared utilities module.

**Estimated Effort:** Small


### [Priority: Medium] Add SpanEvent Helper Methods

**Issue:** `SpanEvent` is a simple data structure with no helper methods for creation or formatting.

**Location:** `Tracer/Core/Span.lean` (lines 15-23)

**Action Required:** Add constructor helpers like `SpanEvent.create` and a `toString` instance.

**Estimated Effort:** Small


### [Priority: Medium] Document Sampling Semantics

**Issue:** The interaction between sampler decisions and the `TraceFlags.sampled` flag is not well documented. The `parentBased` sampler's behavior could confuse users.

**Location:** `Tracer/Sampler.lean`

**Action Required:** Add comprehensive doc comments explaining:
1. When samplers are called
2. How sampling decisions propagate
3. The difference between trace-level and span-level sampling

**Estimated Effort:** Small


### [Priority: Low] Remove Unused `dim` Color in Error Status Display

**Issue:** In `Tracer/Export/Console.lean` line 34, `statusColor` returns `dim` for `.unset` but the display logic at line 76 skips output entirely for unset status, making this code path unused.

**Location:** `Tracer/Export/Console.lean`, line 34

**Action Required:** Either use the color or remove the unreachable branch.

**Estimated Effort:** Small


### [Priority: Low] Add Test for Rate-Limited Sampler

**Issue:** Tests exist for `alwaysOn` and `alwaysOff` samplers but not for `probability` or `rateLimited` samplers.

**Location:** `Tests/Main.lean`

**Action Required:** Add tests for probabilistic and rate-limited sampling behavior.

**Estimated Effort:** Small


### [Priority: Low] Add Test for Span Builder Attribute/Event Addition

**Issue:** Tests verify span creation but don't test `addAttribute`, `addEvent`, or `setStatus` methods.

**Location:** `Tests/Main.lean`

**Action Required:** Add tests that verify:
1. Attributes are added to spans
2. Events are recorded with timestamps
3. Status is properly set on completion

**Estimated Effort:** Small


### [Priority: Low] Improve Console Exporter Tree Formatting

**Issue:** The comment in `Tracer/Export/Console.lean` (lines 83-84) notes that proper tree structure formatting is not implemented. Spans are listed linearly rather than as a hierarchy.

**Location:** `Tracer/Export/Console.lean`, lines 81-86

**Action Required:** Implement proper parent-child tree rendering by sorting spans and adding indentation based on depth.

**Estimated Effort:** Medium


### [Priority: Low] Add Span Name Validation

**Issue:** Span names are accepted as arbitrary strings with no validation or normalization.

**Location:** `Tracer/Tracer.lean`

**Action Required:** Consider adding validation or normalization (trim whitespace, limit length, warn on empty names).

**Estimated Effort:** Small

---

## Summary

This roadmap prioritizes:

1. **Production readiness** (OTLP exporter, Citadel middleware, baggage support)
2. **Code quality** (deduplication, enforcing limits, better types)
3. **Integration** (Wisp, Loom, Chronicle)
4. **Ecosystem expansion** (Zipkin, gRPC, metrics)

The library has a solid foundation with good W3C compliance. The main gaps are in export capabilities and integration with other workspace libraries.
