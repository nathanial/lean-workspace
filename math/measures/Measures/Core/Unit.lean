/-
  Measures.Core.Unit

  The Unit type represents a unit of measurement with a specific dimension.
  It stores conversion factors to/from SI base units, and an optional offset
  for temperature scales.
-/

import Measures.Core.Dimension
import Measures.Core.Quantity

namespace Measures

/-- A unit of measurement with dimension `d`.

    Stores:
    - `name`: Full name (e.g., "meter")
    - `symbol`: Short symbol (e.g., "m")
    - `toSI`: Multiply by this to convert to SI base units
    - `fromSI`: Multiply SI value by this to get this unit (= 1/toSI)
    - `offset`: Additive offset for temperature scales (0 for most units) -/
structure Unit (d : Dimension) where
  name : String
  symbol : String
  toSI : Float
  fromSI : Float
  offset : Float := 0.0
  deriving Repr, Inhabited

namespace Unit

variable {d : Dimension}

/-! ## Construction -/

/-- Create a unit with a scale factor (no offset).
    The `fromSI` factor is computed as `1/toSI`. -/
def scale (name symbol : String) (factor : Float) : Unit d :=
  { name := name
  , symbol := symbol
  , toSI := factor
  , fromSI := 1.0 / factor
  , offset := 0.0 }

/-- Create a unit with both scale and offset (for temperature).
    Conversion: SI = (value + offset) * scale
    Reverse: value = SI / scale - offset -/
def scaleOffset (name symbol : String) (factor offset : Float) : Unit d :=
  { name := name
  , symbol := symbol
  , toSI := factor
  , fromSI := 1.0 / factor
  , offset := offset }

/-- Create an SI base unit (scale = 1, no offset). -/
def siBase (name symbol : String) : Unit d :=
  scale name symbol 1.0

/-! ## Derived Units -/

/-- Apply an SI prefix to a unit (e.g., kilo, milli).
    Returns a new unit with adjusted scale. -/
def withPrefix (u : Unit d) (prefixName prefixSymbol : String) (factor : Float) : Unit d :=
  { name := prefixName ++ u.name
  , symbol := prefixSymbol ++ u.symbol
  , toSI := u.toSI * factor
  , fromSI := u.fromSI / factor
  , offset := u.offset }

/-! ## Compound Unit Construction -/

/-- Multiply two units to produce a compound unit.
    Example: `newton.mul meter` gives a unit for energy (N·m = J).

    Note: Offsets are not supported for compound units. -/
def mul {d1 d2 : Dimension} (u1 : Unit d1) (u2 : Unit d2) : Unit (d1.mul d2) :=
  { name := s!"{u1.name}·{u2.name}"
  , symbol := s!"{u1.symbol}·{u2.symbol}"
  , toSI := u1.toSI * u2.toSI
  , fromSI := u1.fromSI * u2.fromSI
  , offset := 0.0 }

/-- Divide two units to produce a compound unit.
    Example: `meter.div second` gives a unit for velocity (m/s).

    Note: Offsets are not supported for compound units. -/
def div {d1 d2 : Dimension} (u1 : Unit d1) (u2 : Unit d2) : Unit (d1.div d2) :=
  { name := s!"{u1.name}/{u2.name}"
  , symbol := s!"{u1.symbol}/{u2.symbol}"
  , toSI := u1.toSI / u2.toSI
  , fromSI := u1.fromSI / u2.fromSI
  , offset := 0.0 }

/-- Square a unit.
    Example: `meter.sq` gives square meters. -/
def sq (u : Unit d) : Unit (d.pow 2) :=
  { name := s!"{u.name}²"
  , symbol := s!"{u.symbol}²"
  , toSI := u.toSI * u.toSI
  , fromSI := u.fromSI * u.fromSI
  , offset := 0.0 }

/-- Cube a unit.
    Example: `meter.cube` gives cubic meters. -/
def cube (u : Unit d) : Unit (d.pow 3) :=
  { name := s!"{u.name}³"
  , symbol := s!"{u.symbol}³"
  , toSI := u.toSI * u.toSI * u.toSI
  , fromSI := u.fromSI * u.fromSI * u.fromSI
  , offset := 0.0 }

/-- Reciprocal of a unit.
    Example: `second.recip` gives per-second (Hz). -/
def recip (u : Unit d) : Unit d.inv :=
  { name := s!"1/{u.name}"
  , symbol := s!"1/{u.symbol}"
  , toSI := 1.0 / u.toSI
  , fromSI := 1.0 / u.fromSI
  , offset := 0.0 }

/-- Raise a unit to an integer power.
    Example: `meter.pow 2` gives square meters. -/
def pow (u : Unit d) (n : Int) : Unit (d.pow n) :=
  let nFloat : Float := n.toNat.toFloat  -- Note: only works correctly for non-negative n
  { name := s!"{u.name}^{n}"
  , symbol := s!"{u.symbol}^{n}"
  , toSI := if n ≥ 0 then Float.pow u.toSI nFloat else Float.pow (1.0 / u.toSI) (-n).toNat.toFloat
  , fromSI := if n ≥ 0 then Float.pow u.fromSI nFloat else Float.pow (1.0 / u.fromSI) (-n).toNat.toFloat
  , offset := 0.0 }

/-! ## Conversion Functions -/

/-- Create a quantity in this unit.
    Converts the value to SI base units internally. -/
def quantity (u : Unit d) (value : Float) : Quantity d :=
  if u.offset == 0.0 then
    { value := value * u.toSI }
  else
    -- For temperature: SI = (value + offset) * scale
    { value := (value + u.offset) * u.toSI }

/-- Express a quantity in this unit.
    Converts from SI base units to this unit's scale. -/
def fromQuantity (u : Unit d) (q : Quantity d) : Float :=
  if u.offset == 0.0 then
    q.value * u.fromSI
  else
    -- For temperature: value = SI / scale - offset
    q.value * u.fromSI - u.offset

/-- Convert a value directly from one unit to another.
    Example: `convert 100.0 celsius fahrenheit` returns `212.0`

    This is equivalent to `(value *: fromUnit).asUnit toUnit` but
    provides cleaner syntax for simple conversions. -/
def convert (value : Float) (fromUnit toUnit : Unit d) : Float :=
  toUnit.fromQuantity (fromUnit.quantity value)

/-! ## Display -/

instance : ToString (Unit d) where
  toString u := u.symbol

end Unit

/-! ## Operator Instances for Unit Arithmetic -/

/-- Multiply units with `*` operator: `meter * second` -/
instance {d1 d2 : Dimension} : HMul (Unit d1) (Unit d2) (Unit (d1.mul d2)) where
  hMul := Unit.mul

/-- Divide units with `/` operator: `meter / second` -/
instance {d1 d2 : Dimension} : HDiv (Unit d1) (Unit d2) (Unit (d1.div d2)) where
  hDiv := Unit.div

/-! ## Infix Notation -/

/-- Create a quantity: `5.0 *: meter` -/
scoped infixl:75 " *: " => fun (v : Float) (u : Unit _) => Unit.quantity u v

namespace Quantity

variable {d : Dimension}

/-- Express a quantity in a specific unit: `distance.in' foot` -/
def in' (q : Quantity d) (u : Unit d) : Float := u.fromQuantity q

/-- Alias for `in'`: `distance.asUnit foot` -/
def asUnit (q : Quantity d) (u : Unit d) : Float := u.fromQuantity q

/-! ## Pretty Printing -/

/-- Format a float with a given number of decimal places.
    Removes trailing zeros after the decimal point. -/
private def formatFloat (x : Float) (precision : Nat) : String :=
  let factor := Float.pow 10.0 precision.toFloat
  let rounded := Float.round (x * factor) / factor
  let str := s!"{rounded}"
  -- Find decimal point and trim trailing zeros
  match str.splitOn "." with
  | [intPart] => intPart  -- No decimal point
  | [intPart, fracPart] =>
    -- Remove trailing zeros from fractional part
    let trimmed := fracPart.dropRightWhile (· == '0')
    if trimmed.isEmpty then
      intPart
    else
      s!"{intPart}.{trimmed}"
  | _ => str  -- Shouldn't happen, just return as-is

/-- Format a quantity with a unit symbol.
    Example: `distance.format meter` returns `"100 m"`
    Example: `speed.format meterPerSecond 2` returns `"25.5 m/s"` -/
def format (q : Quantity d) (u : Unit d) (precision : Nat := 2) : String :=
  let value := u.fromQuantity q
  s!"{formatFloat value precision} {u.symbol}"

/-- Format a quantity with a unit, showing the full unit name.
    Example: `distance.formatLong meter` returns `"100 meter"` -/
def formatLong (q : Quantity d) (u : Unit d) (precision : Nat := 2) : String :=
  let value := u.fromQuantity q
  s!"{formatFloat value precision} {u.name}"

end Quantity

end Measures
