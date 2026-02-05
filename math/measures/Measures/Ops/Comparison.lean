/-
  Measures.Ops.Comparison

  Comparison operations for quantities.
  Only quantities of the same dimension can be compared.
-/

import Measures.Core.Dimension
import Measures.Core.Quantity

namespace Measures

namespace Quantity

variable {d : Dimension}

/-! ## Equality -/

/-- Check if two quantities are exactly equal. -/
def beq (q1 q2 : Quantity d) : Bool := q1.value == q2.value

instance : BEq (Quantity d) where
  beq := beq

/-- Check if two quantities are approximately equal within a tolerance. -/
def approxEq (q1 q2 : Quantity d) (tolerance : Float := 1e-9) : Bool :=
  Float.abs (q1.value - q2.value) ≤ tolerance

/-- Infix for approximate equality. -/
scoped infix:50 " ≈ " => fun q1 q2 => approxEq q1 q2

/-! ## Ordering -/

/-- Compare two quantities. -/
def compare (q1 q2 : Quantity d) : Ordering :=
  if q1.value < q2.value then Ordering.lt
  else if q1.value > q2.value then Ordering.gt
  else Ordering.eq

instance : Ord (Quantity d) where
  compare := compare

/-- Less than. -/
def lt (q1 q2 : Quantity d) : Bool := q1.value < q2.value

/-- Less than or equal. -/
def le (q1 q2 : Quantity d) : Bool := q1.value ≤ q2.value

/-- Greater than. -/
def gt (q1 q2 : Quantity d) : Bool := q1.value > q2.value

/-- Greater than or equal. -/
def ge (q1 q2 : Quantity d) : Bool := q1.value ≥ q2.value

instance : LT (Quantity d) where
  lt q1 q2 := q1.value < q2.value

instance : LE (Quantity d) where
  le q1 q2 := q1.value ≤ q2.value

/-! ## Range Checks -/

/-- Check if a quantity is within a range (inclusive). -/
def inRange (q lower upper : Quantity d) : Bool :=
  q.value ≥ lower.value && q.value ≤ upper.value

/-- Clamp a quantity to a range. -/
def clamp (q lower upper : Quantity d) : Quantity d :=
  if q.value < lower.value then lower
  else if q.value > upper.value then upper
  else q

end Quantity

end Measures
