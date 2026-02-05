/-
  Tracer.Core.SpanKind - Type of span based on its role

  Indicates whether a span represents a client, server, or internal operation.
-/

namespace Tracer

/-- The type of span based on its role in the trace -/
inductive SpanKind where
  /-- Default kind for internal operations -/
  | internal
  /-- Server-side handling of a synchronous RPC or HTTP request -/
  | server
  /-- Client-side of a synchronous RPC or HTTP request -/
  | client
  /-- Producer in a messaging system (sending a message) -/
  | producer
  /-- Consumer in a messaging system (receiving a message) -/
  | consumer
  deriving Repr, BEq, Inhabited

namespace SpanKind

def toString : SpanKind → String
  | .internal => "INTERNAL"
  | .server => "SERVER"
  | .client => "CLIENT"
  | .producer => "PRODUCER"
  | .consumer => "CONSUMER"

instance : ToString SpanKind where
  toString := SpanKind.toString

end SpanKind
end Tracer
