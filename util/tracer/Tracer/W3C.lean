/-
  Tracer.W3C - W3C Trace Context parsing and formatting

  Implements the W3C Trace Context specification:
  https://www.w3.org/TR/trace-context/

  traceparent format: {version}-{trace-id}-{parent-id}-{flags}
  Example: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01

  tracestate format: key1=value1,key2=value2
-/

import Tracer.Core.TraceContext

namespace Tracer.W3C

/-- Current supported version (always 00) -/
def currentVersion : String := "00"

/-- Parse the traceparent header.
    Format: {version}-{trace-id}-{parent-id}-{flags}
    Example: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01 -/
def parseTraceparent (header : String) : Option TraceContext := do
  -- Split by dash
  let parts := header.splitOn "-"
  if parts.length != 4 then none
  else
    let version := parts[0]!
    let traceIdHex := parts[1]!
    let spanIdHex := parts[2]!
    let flagsHex := parts[3]!

    -- Check version (we only support version 00)
    if version != "00" then none
    else
      -- Parse components
      let traceId ← TraceId.fromHex traceIdHex
      let spanId ← SpanId.fromHex spanIdHex
      let flags ← TraceFlags.fromHex flagsHex

      -- Validate IDs are non-zero
      if !traceId.isValid || !spanId.isValid then none
      else
        some { traceId, spanId, flags }

/-- Format a trace context as a traceparent header -/
def formatTraceparent (ctx : TraceContext) : String :=
  s!"{currentVersion}-{ctx.traceId.toHex}-{ctx.spanId.toHex}-{ctx.flags.toHex}"

/-- Parse the tracestate header.
    Format: key1=value1,key2=value2
    Returns list of key-value pairs. -/
def parseTracestate (header : String) : List (String × String) :=
  if header.isEmpty then []
  else
    let pairs := header.splitOn ","
    pairs.filterMap fun pair =>
      let kv := pair.splitOn "="
      if kv.length >= 2 then
        let key := kv[0]!.trim
        let value := (kv.drop 1).foldl (fun acc s => if acc.isEmpty then s else s!"{acc}={s}") ""
        if key.isEmpty then none
        else some (key, value.trim)
      else none

/-- Format trace state as a tracestate header -/
def formatTracestate (state : List (String × String)) : String :=
  state.map (fun (k, v) => s!"{k}={v}") |> String.intercalate ","

/-- Extract trace context from HTTP headers using a header lookup function -/
def extractContext (getHeader : String → Option String) : Option TraceContext := do
  let traceparent ← getHeader "traceparent"
  let ctx ← parseTraceparent traceparent
  -- Optionally add tracestate if present
  match getHeader "tracestate" with
  | some tracestate =>
    let state := parseTracestate tracestate
    pure (ctx.withTraceState state)
  | none => pure ctx

/-- Inject trace context into HTTP headers.
    Returns list of header name-value pairs. -/
def injectHeaders (ctx : TraceContext) : List (String × String) :=
  let traceparent := ("traceparent", formatTraceparent ctx)
  if ctx.traceState.isEmpty then
    [traceparent]
  else
    [traceparent, ("tracestate", formatTracestate ctx.traceState)]

end Tracer.W3C
