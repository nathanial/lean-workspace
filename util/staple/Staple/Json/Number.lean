/-
  Staple.Json.Number - JSON numeric representation

  JSON numbers can be integers or floating-point. This module provides
  a representation that preserves the original form while supporting
  both efficiently.
-/

namespace Staple.Json

/-- A JSON number, supporting both integer and floating-point values.

    JSON numbers are represented as:
    - Pure integers when there's no decimal point or exponent
    - Floating-point otherwise

    This allows lossless round-trip for integer values while supporting
    the full range of JSON numeric literals. -/
inductive JsonNumber where
  /-- An integer value (no decimal point in original) -/
  | int (value : Int)
  /-- A floating-point value -/
  | float (value : Float)
  deriving Repr, BEq, Inhabited

namespace JsonNumber

/-- Create a JsonNumber from an Int -/
def fromInt (n : Int) : JsonNumber := .int n

/-- Create a JsonNumber from a Nat -/
def fromNat (n : Nat) : JsonNumber := .int n

/-- Create a JsonNumber from a Float -/
def fromFloat (f : Float) : JsonNumber := .float f

/-- Convert to Int, truncating floats -/
def toInt : JsonNumber → Int
  | .int n => n
  | .float f => f.toUInt64.toNat  -- Approximate conversion

/-- Convert to Float -/
def toFloat : JsonNumber → Float
  | .int n => Float.ofInt n
  | .float f => f

/-- Convert to Nat, returning 0 for negative values -/
def toNat : JsonNumber → Nat
  | .int n => if n < 0 then 0 else n.toNat
  | .float f => if f < 0 then 0 else f.toUInt64.toNat

/-- Check if this is an integer (no fractional part) -/
def isInt : JsonNumber → Bool
  | .int _ => true
  | .float f => f == f.floor

/-- Render to string in JSON format -/
def toString : JsonNumber → String
  | .int n => s!"{n}"
  | .float f =>
    let s := s!"{f}"
    -- Ensure we have a decimal point for valid JSON
    if s.contains '.' || s.contains 'e' || s.contains 'E' then s
    else s ++ ".0"

instance : ToString JsonNumber := ⟨JsonNumber.toString⟩

instance (n : Nat) : OfNat JsonNumber n where
  ofNat := .int n

instance : Neg JsonNumber where
  neg
    | .int n => .int (-n)
    | .float f => .float (-f)

instance : Add JsonNumber where
  add a b := .float (a.toFloat + b.toFloat)

instance : Sub JsonNumber where
  sub a b := .float (a.toFloat - b.toFloat)

instance : Mul JsonNumber where
  mul a b := .float (a.toFloat * b.toFloat)

instance : Div JsonNumber where
  div a b := .float (a.toFloat / b.toFloat)

instance : LT JsonNumber where
  lt a b := a.toFloat < b.toFloat

instance : LE JsonNumber where
  le a b := a.toFloat <= b.toFloat

end JsonNumber

end Staple.Json
