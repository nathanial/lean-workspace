/-
  Measures.Units.Imperial

  Imperial and US customary units.
  All units are defined with their conversion factors to SI base units.
-/

import Measures.Core.Unit
import Measures.Dimensions

namespace Measures.Units.Imperial

open Measures
open Dimension

/-! ## Length -/

/-- The inch (2.54 cm exactly). -/
def inch : Unit Length := Unit.scale "inch" "in" 0.0254

/-- The foot (12 inches = 0.3048 m exactly). -/
def foot : Unit Length := Unit.scale "foot" "ft" 0.3048

/-- The yard (3 feet = 0.9144 m exactly). -/
def yard : Unit Length := Unit.scale "yard" "yd" 0.9144

/-- The mile (5280 feet = 1609.344 m exactly). -/
def mile : Unit Length := Unit.scale "mile" "mi" 1609.344

/-- The nautical mile (1852 m exactly). -/
def nauticalMile : Unit Length := Unit.scale "nautical mile" "nmi" 1852.0

/-- The thou/mil (0.001 inch). -/
def thou : Unit Length := Unit.scale "thou" "th" 0.0000254

/-! ## Mass -/

/-- The pound (avoirdupois, 0.45359237 kg exactly). -/
def pound : Unit Mass := Unit.scale "pound" "lb" 0.45359237

/-- The ounce (1/16 pound). -/
def ounce : Unit Mass := Unit.scale "ounce" "oz" 0.028349523125

/-- The stone (14 pounds). -/
def stone : Unit Mass := Unit.scale "stone" "st" 6.35029318

/-- The short ton (US, 2000 pounds). -/
def shortTon : Unit Mass := Unit.scale "short ton" "ton" 907.18474

/-- The long ton (UK, 2240 pounds). -/
def longTon : Unit Mass := Unit.scale "long ton" "long ton" 1016.0469088

/-- The grain (1/7000 pound). -/
def grain : Unit Mass := Unit.scale "grain" "gr" 0.00006479891

/-! ## Volume (US) -/

/-- The US fluid ounce. -/
def fluidOunce : Unit Volume := Unit.scale "fluid ounce" "fl oz" 2.95735295625e-5

/-- The US cup (8 fluid ounces). -/
def cup : Unit Volume := Unit.scale "cup" "cup" 2.365882365e-4

/-- The US pint (2 cups). -/
def pint : Unit Volume := Unit.scale "pint" "pt" 4.73176473e-4

/-- The US quart (2 pints). -/
def quart : Unit Volume := Unit.scale "quart" "qt" 9.46352946e-4

/-- The US gallon (4 quarts = 3.785411784 L). -/
def gallon : Unit Volume := Unit.scale "gallon" "gal" 3.785411784e-3

/-- The US tablespoon (1/2 fluid ounce). -/
def tablespoon : Unit Volume := Unit.scale "tablespoon" "tbsp" 1.47867647813e-5

/-- The US teaspoon (1/3 tablespoon). -/
def teaspoon : Unit Volume := Unit.scale "teaspoon" "tsp" 4.92892159375e-6

/-- The cubic inch. -/
def cubicInch : Unit Volume := Unit.scale "cubic inch" "in³" 1.6387064e-5

/-- The cubic foot. -/
def cubicFoot : Unit Volume := Unit.scale "cubic foot" "ft³" 0.028316846592

/-! ## Volume (UK/Imperial) -/

/-- The Imperial fluid ounce. -/
def imperialFluidOunce : Unit Volume := Unit.scale "imperial fluid ounce" "imp fl oz" 2.84130625e-5

/-- The Imperial pint (20 imperial fluid ounces). -/
def imperialPint : Unit Volume := Unit.scale "imperial pint" "imp pt" 5.6826125e-4

/-- The Imperial gallon (8 imperial pints = 4.54609 L). -/
def imperialGallon : Unit Volume := Unit.scale "imperial gallon" "imp gal" 4.54609e-3

/-! ## Area -/

/-- The square inch. -/
def squareInch : Unit Area := Unit.scale "square inch" "in²" 6.4516e-4

/-- The square foot. -/
def squareFoot : Unit Area := Unit.scale "square foot" "ft²" 0.09290304

/-- The square yard. -/
def squareYard : Unit Area := Unit.scale "square yard" "yd²" 0.83612736

/-- The acre. -/
def acre : Unit Area := Unit.scale "acre" "ac" 4046.8564224

/-- The square mile. -/
def squareMile : Unit Area := Unit.scale "square mile" "mi²" 2589988.110336

/-! ## Velocity -/

/-- Miles per hour. -/
def milePerHour : Unit Velocity := Unit.scale "mile per hour" "mph" 0.44704

/-- Feet per second. -/
def footPerSecond : Unit Velocity := Unit.scale "foot per second" "ft/s" 0.3048

/-- Knot (nautical miles per hour). -/
def knot : Unit Velocity := Unit.scale "knot" "kn" 0.514444

/-! ## Force -/

/-- The pound-force. -/
def poundForce : Unit Force := Unit.scale "pound-force" "lbf" 4.4482216152605

/-! ## Pressure -/

/-- Pounds per square inch. -/
def psi : Unit Pressure := Unit.scale "pound per square inch" "psi" 6894.757293168

/-! ## Energy -/

/-- The British thermal unit (IT). -/
def btu : Unit Energy := Unit.scale "British thermal unit" "BTU" 1055.05585262

/-- The foot-pound. -/
def footPound : Unit Energy := Unit.scale "foot-pound" "ft·lb" 1.3558179483314

/-! ## Power -/

/-- Horsepower (mechanical). -/
def horsepower : Unit Power := Unit.scale "horsepower" "hp" 745.69987158227

/-! ## Aliases -/

abbrev in_ := inch  -- 'in' is a keyword
abbrev ft := foot
abbrev yd := yard
abbrev mi := mile
abbrev lb := pound
abbrev oz := ounce
abbrev gal := gallon
abbrev mph := milePerHour
abbrev hp := horsepower

end Measures.Units.Imperial
