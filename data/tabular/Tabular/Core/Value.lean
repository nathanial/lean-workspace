/-
  Tabular.Core.Value
  Cell value type - always stored as raw string content
-/

namespace Tabular

/-- A cell value - always stored as the raw string content.
    Type conversion happens via FromCsv at extraction time. -/
structure Value where
  content : String
  deriving Repr, Inhabited, BEq

namespace Value

/-- Empty cell value -/
def empty : Value := { content := "" }

/-- Check if value is empty -/
def isEmpty (v : Value) : Bool := v.content.isEmpty

/-- Get raw string content -/
def toString (v : Value) : String := v.content

/-- Get trimmed content -/
def trim (v : Value) : String := v.content.trim

instance : ToString Value where
  toString := Value.toString

end Value

end Tabular
