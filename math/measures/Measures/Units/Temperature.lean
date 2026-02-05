/-
  Measures.Units.Temperature

  Temperature units with offset handling for Celsius and Fahrenheit.

  Note: Temperature is tricky because Celsius and Fahrenheit have offsets,
  not just scale factors. A temperature *difference* of 1°C = 1K, but
  a temperature *value* of 0°C = 273.15K.

  This library treats temperatures as absolute values, so:
  - 20°C is stored as 293.15K internally
  - Temperature differences should use Kelvin or be aware of this
-/

import Measures.Core.Unit
import Measures.Dimensions
import Measures.Units.SI

namespace Measures.Units.Temperature

open Measures
open Dimension

/-! ## Absolute Temperature Scales -/

/-- Kelvin - SI unit of thermodynamic temperature (re-exported from SI).
    Absolute scale, 0K = absolute zero. -/
abbrev kelvin : Unit Temperature := Units.SI.kelvin

/-- Rankine - Absolute scale using Fahrenheit-sized degrees.
    0°R = absolute zero, 1°R = 1°F temperature difference. -/
def rankine : Unit Temperature := Unit.scale "rankine" "°R" (5.0 / 9.0)

/-! ## Relative Temperature Scales

These have offsets from absolute zero. -/

/-- Celsius (Centigrade).
    0°C = 273.15K (freezing point of water)
    Conversion: K = °C + 273.15 -/
def celsius : Unit Temperature :=
  Unit.scaleOffset "degree Celsius" "°C" 1.0 273.15

/-- Fahrenheit.
    32°F = 273.15K (freezing point of water)
    Conversion: K = (°F + 459.67) × 5/9 -/
def fahrenheit : Unit Temperature :=
  Unit.scaleOffset "degree Fahrenheit" "°F" (5.0 / 9.0) 459.67

/-! ## Reference Temperatures -/

/-- Absolute zero (0K). -/
def absoluteZero : Quantity Temperature := 0.0 *: kelvin

/-- Freezing point of water at 1 atm (273.15K = 0°C = 32°F). -/
def waterFreezing : Quantity Temperature := 273.15 *: kelvin

/-- Boiling point of water at 1 atm (373.15K = 100°C = 212°F). -/
def waterBoiling : Quantity Temperature := 373.15 *: kelvin

/-- Standard temperature (293.15K = 20°C = 68°F). -/
def standardTemperature : Quantity Temperature := 293.15 *: kelvin

/-- Room temperature (approximately 295K = 22°C = 72°F). -/
def roomTemperature : Quantity Temperature := 295.0 *: kelvin

/-! ## Temperature Difference Type

For temperature *differences* (not absolute temperatures), the offset
doesn't apply. Use these when computing ΔT. -/

/-- One Kelvin of temperature difference. -/
def kelvinDelta : Unit Temperature := Unit.scale "kelvin" "K" 1.0

/-- One Celsius degree of temperature difference (= 1K). -/
def celsiusDelta : Unit Temperature := Unit.scale "°C" "°C" 1.0

/-- One Fahrenheit degree of temperature difference (= 5/9 K). -/
def fahrenheitDelta : Unit Temperature := Unit.scale "°F" "°F" (5.0 / 9.0)

/-! ## Aliases -/

abbrev K := kelvin
abbrev degC := celsius
abbrev degF := fahrenheit
abbrev degR := rankine

end Measures.Units.Temperature
