/-
  Chronicle.Format - Log entry formatting

  Provides text and JSON output formats for log entries.
-/

import Chronicle.Level

namespace Chronicle

/-- Output format for log entries -/
inductive Format where
  | text  -- Plain text: [timestamp] [LEVEL] message
  | json  -- JSON: {"timestamp":...,"level":"...","message":"..."}
deriving Repr, BEq

/-- A structured log entry with optional HTTP request context -/
structure LogEntry where
  /-- Timestamp in nanoseconds (from IO.monoNanosNow) -/
  timestamp : Nat
  /-- Log level -/
  level : Level
  /-- Log message -/
  message : String
  /-- Optional key-value context pairs -/
  context : List (String × String) := []
  /-- Optional request ID for correlation -/
  requestId : Option String := none
  /-- Optional HTTP path -/
  path : Option String := none
  /-- Optional HTTP method -/
  method : Option String := none
  /-- Optional HTTP status code -/
  statusCode : Option Nat := none
  /-- Optional request duration in milliseconds -/
  durationMs : Option Float := none
deriving Repr

namespace LogEntry

/-- Format timestamp as seconds.milliseconds -/
private def formatTimestamp (nanos : Nat) : String :=
  let ms := nanos / 1000000
  let secs := ms / 1000
  let millis := ms % 1000
  let millisStr := Nat.repr millis
  let paddedMillis := String.ofList (List.replicate (3 - millisStr.length) '0') ++ millisStr
  s!"{secs}.{paddedMillis}"

/-- Format entry as plain text -/
def formatText (entry : LogEntry) : String :=
  let ts := formatTimestamp entry.timestamp
  let level := entry.level.padded
  let base := s!"[{ts}] [{level}] {entry.message}"
  match entry.durationMs with
  | some ms =>
    let msStr := Float.toString ms
    let truncated := msStr.take 8
    s!"{base} ({truncated}ms)"
  | none => base

/-- Escape special characters for JSON strings -/
private def escapeJson (s : String) : String :=
  s.foldl (fun acc c =>
    match c with
    | '"' => acc ++ "\\\""
    | '\\' => acc ++ "\\\\"
    | '\n' => acc ++ "\\n"
    | '\r' => acc ++ "\\r"
    | '\t' => acc ++ "\\t"
    | c => acc.push c
  ) ""

/-- Format entry as JSON -/
def formatJson (entry : LogEntry) : String :=
  let parts := [
    s!"\"timestamp\":{entry.timestamp}",
    s!"\"level\":\"{entry.level.toString}\"",
    s!"\"message\":\"{escapeJson entry.message}\""
  ]
  let optParts := [
    entry.path.map fun p => s!"\"path\":\"{escapeJson p}\"",
    entry.method.map fun m => s!"\"method\":\"{m}\"",
    entry.statusCode.map fun c => s!"\"status\":{c}",
    entry.durationMs.map fun d => s!"\"duration_ms\":{d}",
    entry.requestId.map fun r => s!"\"request_id\":\"{escapeJson r}\""
  ].filterMap id
  -- Add context if present
  let contextPart :=
    if entry.context.isEmpty then []
    else
      let pairs := entry.context.map fun (k, v) => s!"\"{escapeJson k}\":\"{escapeJson v}\""
      ["\"context\":{" ++ ",".intercalate pairs ++ "}"]
  let allParts := parts ++ optParts ++ contextPart
  "{" ++ ",".intercalate allParts ++ "}"

/-- Format entry using the specified format -/
def format (entry : LogEntry) (fmt : Format) : String :=
  match fmt with
  | .text => entry.formatText
  | .json => entry.formatJson

end LogEntry
end Chronicle
