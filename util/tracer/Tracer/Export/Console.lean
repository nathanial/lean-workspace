/-
  Tracer.Export.Console - Console exporter for development

  Pretty-prints spans to stderr for debugging and development.
-/

import Tracer.Core.Span
import Tracer.Config

namespace Tracer.Export.Console

/-- ANSI color codes -/
private def reset : String := "\x1b[0m"
private def dim : String := "\x1b[2m"
private def bold : String := "\x1b[1m"
private def green : String := "\x1b[32m"
private def yellow : String := "\x1b[33m"
private def red : String := "\x1b[31m"
private def cyan : String := "\x1b[36m"
private def magenta : String := "\x1b[35m"

/-- Get color for span kind -/
private def kindColor : SpanKind → String
  | .server => cyan
  | .client => magenta
  | .internal => dim
  | .producer => yellow
  | .consumer => yellow

/-- Get color for status -/
private def statusColor : SpanStatus → String
  | .ok => green
  | .error _ => red
  | .unset => dim

/-- Format duration in human-readable form -/
private def formatDuration (nanos : Nat) : String :=
  let ms := Float.ofNat nanos / 1_000_000.0
  if ms < 1.0 then
    let us := Float.ofNat nanos / 1_000.0
    s!"{us.round}μs"
  else if ms < 1000.0 then
    s!"{ms.round}ms"
  else
    let s := ms / 1000.0
    s!"{s}s"

/-- Format a single span for console output -/
def formatSpan (span : Span) (indent : String := "") : String :=
  let kind := span.kind.toString
  let kindCol := kindColor span.kind
  let statusCol := statusColor span.status
  let duration := formatDuration span.durationNanos
  let traceIdShort := span.traceId.toHex.take 8
  let spanIdShort := span.spanId.toHex.take 8

  let statusStr := match span.status with
    | .ok => s!"{green}OK{reset}"
    | .error msg => s!"{red}ERR{reset} {dim}{msg}{reset}"
    | .unset => ""

  let header := s!"{indent}{bold}[SPAN]{reset} {kindCol}{kind}{reset} {span.name} {dim}({duration}){reset}"
  let ids := s!"{indent}       {dim}trace={traceIdShort} span={spanIdShort}{reset}"

  let attrs := if span.attributes.isEmpty then ""
    else
      let attrStr := span.attributes.toList.map toString |> String.intercalate ", "
      s!"\n{indent}       {dim}attrs: {attrStr}{reset}"

  let events := if span.events.isEmpty then ""
    else
      let eventStrs := span.events.toList.map fun e =>
        s!"\n{indent}       {dim}• {e.name}{reset}"
      String.join eventStrs

  let status := if span.status == .unset then ""
    else s!"\n{indent}       {statusCol}status: {statusStr}{reset}"

  s!"{header}\n{ids}{attrs}{events}{status}"

/-- Format spans as a tree structure -/
def formatSpanTree (spans : Array Span) : String :=
  -- For simplicity, just format each span with its trace/span hierarchy indicated
  -- A full tree structure would require sorting by parent relationships
  let lines := spans.toList.map (formatSpan · "")
  String.intercalate "\n" lines

/-- Console exporter configuration -/
structure Config where
  /-- Whether to use colors -/
  useColors : Bool := true
  /-- Output stream (stderr by default) -/
  useStderr : Bool := true
  deriving Inhabited

/-- Create a console exporter -/
def exporter (config : Config := {}) : Exporter := {
  exportSpans := fun spans => do
    if spans.isEmpty then return ()
    let output := formatSpanTree spans
    if config.useStderr then
      IO.eprintln output
    else
      IO.println output
  shutdown := pure ()
}

/-- Default console exporter -/
def default : Exporter := exporter {}

end Tracer.Export.Console
