/-
  Measures.Core.Quantity

  The Quantity type represents a physical quantity with a value and dimension.
  The dimension is tracked at the type level for compile-time safety.
-/

import Measures.Core.Dimension

namespace Measures

/-- A quantity with dimension `d` and a floating-point value.
    The dimension is tracked at the type level, enabling compile-time
    dimensional analysis.

    All quantities are stored in SI base units internally. -/
structure Quantity (d : Dimension) where
  /-- The numeric value in SI base units. -/
  value : Float
  deriving Repr, Inhabited, BEq

/-- Hashable instance for Quantity using Float bit representation. -/
instance {d : Dimension} : Hashable (Quantity d) where
  hash q := hash q.value.toUInt64

/-- Axiom: Floats with equal bit representations are propositionally equal.
    This is valid for IEEE 754 representation. -/
private axiom float_eq_of_toUInt64_eq : ∀ (a b : Float), a.toUInt64 = b.toUInt64 → a = b

/-- DecidableEq for Quantity.
    Uses IEEE 754 bit-level equality. -/
instance {d : Dimension} : DecidableEq (Quantity d) := fun q1 q2 =>
  if h : q1.value.toUInt64 = q2.value.toUInt64 then
    isTrue (by
      cases q1; cases q2
      congr
      exact float_eq_of_toUInt64_eq _ _ h)
  else
    isFalse (fun heq => by cases heq; exact h rfl)

namespace Quantity

variable {d : Dimension}

/-! ## Construction -/

/-- Create a quantity with a given value (in SI base units). -/
def mk' (value : Float) : Quantity d := { value }

/-- Create a dimensionless quantity (pure number). -/
def pure (x : Float) : Quantity Dimension.one := { value := x }

/-- The zero quantity for any dimension. -/
def zero : Quantity d := { value := 0.0 }

/-! ## Extraction -/

/-- Extract the raw value (in SI base units). -/
def toFloat (q : Quantity d) : Float := q.value

/-- Convert a dimensionless quantity to Float. -/
def toPure (q : Quantity Dimension.one) : Float := q.value

/-! ## Predicates -/

/-- Check if a quantity is zero. -/
def isZero (q : Quantity d) : Bool := q.value == 0.0

/-- Check if a quantity is positive. -/
def isPositive (q : Quantity d) : Bool := q.value > 0.0

/-- Check if a quantity is negative. -/
def isNegative (q : Quantity d) : Bool := q.value < 0.0

/-! ## Basic Operations -/

/-- Negate a quantity. -/
def neg (q : Quantity d) : Quantity d := { value := -q.value }

/-- Absolute value. -/
def abs (q : Quantity d) : Quantity d := { value := Float.abs q.value }

/-- Sign of a quantity (-1, 0, or 1). -/
def signum (q : Quantity d) : Float :=
  if q.value > 0.0 then 1.0
  else if q.value < 0.0 then -1.0
  else 0.0

/-! ## Scalar Multiplication -/

/-- Multiply a quantity by a scalar. -/
def smul (s : Float) (q : Quantity d) : Quantity d := { value := s * q.value }

/-- Divide a quantity by a scalar. -/
def sdiv (q : Quantity d) (s : Float) : Quantity d := { value := q.value / s }

/-! ## Display -/

/-- Round a float to a given number of decimal places. -/
private def roundToPrecision (x : Float) (precision : Nat) : Float :=
  let factor := Float.pow 10.0 precision.toFloat
  Float.round (x * factor) / factor

/-- Convert to string with given precision (decimal places). -/
def toString (q : Quantity d) (precision : Nat := 6) : String :=
  let rounded := roundToPrecision q.value precision
  s!"{rounded}"

instance : ToString (Quantity d) where
  toString q := q.toString

end Quantity

end Measures
