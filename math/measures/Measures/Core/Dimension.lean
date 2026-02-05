/-
  Measures.Core.Dimension

  The Dimension type represents physical dimensions using integer exponents
  for the 7 SI base dimensions. This enables compile-time dimensional analysis.
-/

namespace Measures

/-- The 7 SI base dimensions as integer exponents.
    Each field represents the power of that dimension.

    Examples:
    - Length (meter): `{length := 1, ...rest := 0}`
    - Velocity (m/s): `{length := 1, time := -1, ...rest := 0}`
    - Force (N = kg·m/s²): `{mass := 1, length := 1, time := -2, ...rest := 0}` -/
structure Dimension where
  length      : Int := 0  -- meter (m)
  mass        : Int := 0  -- kilogram (kg)
  time        : Int := 0  -- second (s)
  current     : Int := 0  -- ampere (A)
  temperature : Int := 0  -- kelvin (K)
  amount      : Int := 0  -- mole (mol)
  luminosity  : Int := 0  -- candela (cd)
  deriving Repr, BEq, DecidableEq, Inhabited, Hashable

namespace Dimension

/-! ## Dimensionless -/

/-- The dimensionless dimension (pure number).
    All exponents are zero. Identity for multiplication. -/
def one : Dimension := {}

/-- Check if a dimension is dimensionless. -/
def isDimensionless (d : Dimension) : Bool :=
  d.length == 0 && d.mass == 0 && d.time == 0 &&
  d.current == 0 && d.temperature == 0 &&
  d.amount == 0 && d.luminosity == 0

/-! ## Dimension Arithmetic -/

/-- Multiply dimensions (add exponents).
    Used when multiplying quantities: `(m) * (s) = (m·s)` -/
def mul (d1 d2 : Dimension) : Dimension :=
  { length      := d1.length + d2.length
  , mass        := d1.mass + d2.mass
  , time        := d1.time + d2.time
  , current     := d1.current + d2.current
  , temperature := d1.temperature + d2.temperature
  , amount      := d1.amount + d2.amount
  , luminosity  := d1.luminosity + d2.luminosity }

/-- Divide dimensions (subtract exponents).
    Used when dividing quantities: `(m) / (s) = (m/s)` -/
def div (d1 d2 : Dimension) : Dimension :=
  { length      := d1.length - d2.length
  , mass        := d1.mass - d2.mass
  , time        := d1.time - d2.time
  , current     := d1.current - d2.current
  , temperature := d1.temperature - d2.temperature
  , amount      := d1.amount - d2.amount
  , luminosity  := d1.luminosity - d2.luminosity }

/-- Raise dimension to an integer power.
    Used for operations like squaring: `(m)² = (m²)` -/
def pow (d : Dimension) (n : Int) : Dimension :=
  { length      := d.length * n
  , mass        := d.mass * n
  , time        := d.time * n
  , current     := d.current * n
  , temperature := d.temperature * n
  , amount      := d.amount * n
  , luminosity  := d.luminosity * n }

/-- Invert a dimension (negate all exponents).
    Used for reciprocals: `1/(m/s) = (s/m)` -/
def inv (d : Dimension) : Dimension :=
  { length      := -d.length
  , mass        := -d.mass
  , time        := -d.time
  , current     := -d.current
  , temperature := -d.temperature
  , amount      := -d.amount
  , luminosity  := -d.luminosity }

/-- Check if a dimension can be square-rooted (all exponents even). -/
def canSqrt (d : Dimension) : Bool :=
  d.length % 2 == 0 && d.mass % 2 == 0 && d.time % 2 == 0 &&
  d.current % 2 == 0 && d.temperature % 2 == 0 &&
  d.amount % 2 == 0 && d.luminosity % 2 == 0

/-- Square root of a dimension (halve all exponents).
    Only valid if all exponents are even. -/
def sqrt (d : Dimension) : Dimension :=
  { length      := d.length / 2
  , mass        := d.mass / 2
  , time        := d.time / 2
  , current     := d.current / 2
  , temperature := d.temperature / 2
  , amount      := d.amount / 2
  , luminosity  := d.luminosity / 2 }

/-! ## Operator Instances -/

instance : Mul Dimension where
  mul := mul

instance : Div Dimension where
  div := div

instance : HPow Dimension Int Dimension where
  hPow := pow

end Dimension

end Measures
