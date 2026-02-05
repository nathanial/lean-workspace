/-
  Measures.Units.Angle

  Angular units. Angles are dimensionless (ratio of arc length to radius),
  but we provide unit support for convenience.
-/

import Measures.Core.Unit
import Measures.Dimensions
import Measures.Constants

namespace Measures.Units.Angle

open Measures
open Measures.Constants
open Dimension

/-! ## Angle Units

Angles are dimensionless quantities (the SI considers radian = m/m = 1).
We define them as dimensionless units for convenience. -/

/-- The radian - SI unit of plane angle.
    One radian is the angle subtended by an arc equal to the radius. -/
def radian : Unit Dimensionless := Unit.siBase "radian" "rad"

/-- The degree - 1/360 of a full rotation.
    π/180 radians. -/
def degree : Unit Dimensionless := Unit.scale "degree" "°" (π / 180.0)

/-- The gradian (gon) - 1/400 of a full rotation.
    π/200 radians. -/
def gradian : Unit Dimensionless := Unit.scale "gradian" "gon" (π / 200.0)

/-- The turn (revolution) - one complete rotation.
    2π radians. -/
def turn : Unit Dimensionless := Unit.scale "turn" "tr" (2.0 * π)

/-- The arcminute - 1/60 of a degree.
    π/10800 radians. -/
def arcminute : Unit Dimensionless := Unit.scale "arcminute" "'" (π / 10800.0)

/-- The arcsecond - 1/60 of an arcminute.
    π/648000 radians. -/
def arcsecond : Unit Dimensionless := Unit.scale "arcsecond" "\"" (π / 648000.0)

/-- The milliradian. -/
def milliradian : Unit Dimensionless := Unit.scale "milliradian" "mrad" 0.001

/-! ## Common Angle Constants -/

/-- π radians (180°). -/
def piAngle : Quantity Dimensionless := π *: radian

/-- 2π radians (360°, full rotation). -/
def twoPiAngle : Quantity Dimensionless := (2.0 * π) *: radian

/-- π/2 radians (90°, right angle). -/
def halfPiAngle : Quantity Dimensionless := (π / 2.0) *: radian

/-- π/4 radians (45°). -/
def quarterPiAngle : Quantity Dimensionless := (π / 4.0) *: radian

/-! ## Angle Utilities -/

/-- Normalize an angle to [0, 2π). -/
def normalizePositive (angle : Quantity Dimensionless) : Quantity Dimensionless :=
  let twoPiVal := 2.0 * π
  let normalized := angle.value - twoPiVal * Float.floor (angle.value / twoPiVal)
  { value := normalized }

/-- Normalize an angle to [-π, π). -/
def normalizeSigned (angle : Quantity Dimensionless) : Quantity Dimensionless :=
  let twoPiVal := 2.0 * π
  let piVal := π
  let normalized := angle.value - twoPiVal * Float.floor ((angle.value + piVal) / twoPiVal)
  { value := normalized }

/-! ## Solid Angle

Solid angles are also dimensionless (sr = m²/m² = 1). -/

/-- The steradian - SI unit of solid angle.
    The solid angle subtended by a surface equal to the square of the radius. -/
def steradian : Unit Dimensionless := Unit.siBase "steradian" "sr"

/-- The square degree. -/
def squareDegree : Unit Dimensionless :=
  Unit.scale "square degree" "deg²" ((π / 180.0) * (π / 180.0))

/-- The full sphere (4π steradians). -/
def sphere : Unit Dimensionless := Unit.scale "sphere" "sp" (4.0 * π)

/-! ## Aliases -/

abbrev rad := radian
abbrev deg := degree
abbrev gon := gradian
abbrev rev := turn
abbrev sr := steradian

end Measures.Units.Angle
