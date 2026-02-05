/-
  Tracer.Core.SpanStatus - Result status of a span

  Indicates whether the operation completed successfully or with an error.
-/

namespace Tracer

/-- Result status of a span -/
inductive SpanStatus where
  /-- Status has not been set -/
  | unset
  /-- Operation completed successfully -/
  | ok
  /-- Operation completed with an error -/
  | error (message : String)
  deriving Repr, BEq, Inhabited

namespace SpanStatus

def isError : SpanStatus → Bool
  | .error _ => true
  | _ => false

def isOk : SpanStatus → Bool
  | .ok => true
  | _ => false

def toString : SpanStatus → String
  | .unset => "UNSET"
  | .ok => "OK"
  | .error msg => s!"ERROR: {msg}"

instance : ToString SpanStatus where
  toString := SpanStatus.toString

end SpanStatus
end Tracer
