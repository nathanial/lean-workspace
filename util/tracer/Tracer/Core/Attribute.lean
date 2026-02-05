/-
  Tracer.Core.Attribute - Span attributes (key-value pairs)

  Attributes provide additional context about a span, such as
  HTTP method, URL, database queries, etc.
-/

namespace Tracer

/-- Typed attribute values -/
inductive AttributeValue where
  | string (v : String)
  | int (v : Int)
  | float (v : Float)
  | bool (v : Bool)
  | stringArray (v : Array String)
  | intArray (v : Array Int)
  deriving Repr, BEq, Inhabited

namespace AttributeValue

def toString : AttributeValue → String
  | .string v => v
  | .int v => ToString.toString v
  | .float v => ToString.toString v
  | .bool v => if v then "true" else "false"
  | .stringArray v => s!"[{String.intercalate ", " v.toList}]"
  | .intArray v => s!"[{String.intercalate ", " (v.toList.map ToString.toString)}]"

instance : ToString AttributeValue where
  toString := AttributeValue.toString

end AttributeValue

/-- A span attribute (key-value pair) -/
structure Attribute where
  key : String
  value : AttributeValue
  deriving Repr, BEq, Inhabited

namespace Attribute

def string (key : String) (value : String) : Attribute :=
  { key, value := .string value }

def int (key : String) (value : Int) : Attribute :=
  { key, value := .int value }

def float (key : String) (value : Float) : Attribute :=
  { key, value := .float value }

def bool (key : String) (value : Bool) : Attribute :=
  { key, value := .bool value }

def toString (a : Attribute) : String :=
  s!"{a.key}={a.value}"

instance : ToString Attribute where
  toString := Attribute.toString

end Attribute

-- Common semantic convention attributes
namespace Attributes

/-- HTTP request method -/
def httpMethod (method : String) : Attribute :=
  Attribute.string "http.method" method

/-- Full HTTP request URL -/
def httpUrl (url : String) : Attribute :=
  Attribute.string "http.url" url

/-- HTTP response status code -/
def httpStatusCode (code : Nat) : Attribute :=
  Attribute.int "http.status_code" code

/-- HTTP route pattern -/
def httpRoute (route : String) : Attribute :=
  Attribute.string "http.route" route

/-- Database system (e.g., "postgresql", "mysql") -/
def dbSystem (system : String) : Attribute :=
  Attribute.string "db.system" system

/-- Database statement -/
def dbStatement (stmt : String) : Attribute :=
  Attribute.string "db.statement" stmt

/-- Database name -/
def dbName (name : String) : Attribute :=
  Attribute.string "db.name" name

/-- Network peer address -/
def netPeerName (name : String) : Attribute :=
  Attribute.string "net.peer.name" name

/-- Network peer port -/
def netPeerPort (port : Nat) : Attribute :=
  Attribute.int "net.peer.port" port

/-- Error type/exception type -/
def exceptionType (typ : String) : Attribute :=
  Attribute.string "exception.type" typ

/-- Error message -/
def exceptionMessage (msg : String) : Attribute :=
  Attribute.string "exception.message" msg

end Attributes
end Tracer
