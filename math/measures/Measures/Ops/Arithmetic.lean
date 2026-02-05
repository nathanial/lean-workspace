/-
  Measures.Ops.Arithmetic

  Arithmetic operations on quantities with dimension tracking.
  Addition and subtraction require matching dimensions.
  Multiplication and division combine dimensions.
-/

import Measures.Core.Dimension
import Measures.Core.Quantity

namespace Measures

namespace Quantity

variable {d d1 d2 : Dimension}

/-! ## Addition and Subtraction

These operations require quantities of the same dimension.
The dimension is preserved in the result. -/

/-- Add two quantities of the same dimension. -/
def add (q1 q2 : Quantity d) : Quantity d :=
  { value := q1.value + q2.value }

/-- Subtract two quantities of the same dimension. -/
def sub (q1 q2 : Quantity d) : Quantity d :=
  { value := q1.value - q2.value }

instance : Add (Quantity d) where
  add := add

instance : Sub (Quantity d) where
  sub := sub

instance : Neg (Quantity d) where
  neg := neg

/-! ## Multiplication and Division

These operations combine dimensions:
- Multiplication adds exponents
- Division subtracts exponents -/

/-- Multiply two quantities, combining their dimensions. -/
def mul (q1 : Quantity d1) (q2 : Quantity d2) : Quantity (d1.mul d2) :=
  { value := q1.value * q2.value }

/-- Divide two quantities, combining their dimensions. -/
def div (q1 : Quantity d1) (q2 : Quantity d2) : Quantity (d1.div d2) :=
  { value := q1.value / q2.value }

/-- Square a quantity (dimension exponents doubled). -/
def sq (q : Quantity d) : Quantity (d.pow 2) :=
  { value := q.value * q.value }

/-- Cube a quantity (dimension exponents tripled). -/
def cube (q : Quantity d) : Quantity (d.pow 3) :=
  { value := q.value * q.value * q.value }

/-- Reciprocal of a quantity (dimension exponents negated). -/
def recip (q : Quantity d) : Quantity d.inv :=
  { value := 1.0 / q.value }

/-- Raise a quantity to an integer power. -/
def pow (q : Quantity d) (n : Int) : Quantity (d.pow n) :=
  { value := Float.pow q.value (Float.ofInt n) }

/-! ## Square Root

Only valid for dimensions with all even exponents.
Returns dimensionless if input is dimensionless. -/

/-- Square root of a quantity.
    Note: Caller must ensure dimension exponents are even. -/
def sqrt (q : Quantity d) : Quantity d.sqrt :=
  { value := Float.sqrt q.value }

/-! ## Infix Operators

We use `*.` and `/.` to distinguish from regular arithmetic,
since these change the result type. -/

scoped infixl:70 " *. " => mul
scoped infixl:70 " /. " => div

/-! ## Scalar Operations -/

/-- Scalar multiplication (Float * Quantity). -/
scoped notation:75 s:75 " • " q:76 => smul s q

/-- Scalar multiplication (Quantity * Float). -/
def mulScalar (q : Quantity d) (s : Float) : Quantity d :=
  { value := q.value * s }

/-- Scalar division (Quantity / Float). -/
def divScalar (q : Quantity d) (s : Float) : Quantity d :=
  { value := q.value / s }

instance : HMul (Quantity d) Float (Quantity d) where
  hMul := mulScalar

/-- Scalar multiplication (Float * Quantity). -/
def scalarMul (s : Float) (q : Quantity d) : Quantity d :=
  { value := s * q.value }

instance : HMul Float (Quantity d) (Quantity d) where
  hMul := scalarMul

instance : HDiv (Quantity d) Float (Quantity d) where
  hDiv := divScalar

/-! ## Convenience Functions -/

/-- Sum a list of quantities. -/
def sum (qs : List (Quantity d)) : Quantity d :=
  qs.foldl add zero

/-- Average of a list of quantities. -/
def avg (qs : List (Quantity d)) : Quantity d :=
  if qs.isEmpty then zero
  else sdiv (sum qs) qs.length.toFloat

/-- Minimum of two quantities. -/
def min (q1 q2 : Quantity d) : Quantity d :=
  if q1.value ≤ q2.value then q1 else q2

/-- Maximum of two quantities. -/
def max (q1 q2 : Quantity d) : Quantity d :=
  if q1.value ≥ q2.value then q1 else q2

end Quantity

end Measures
