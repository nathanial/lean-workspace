/-
  Measures.Units.SI

  SI (International System of Units) base and derived units.
  All units are defined with their conversion factors to SI base units.
-/

import Measures.Core.Unit
import Measures.Dimensions

namespace Measures.Units.SI

open Measures
open Dimension

/-! ## SI Base Units -/

/-- The meter - SI unit of length. -/
def meter : Unit Length := Unit.siBase "meter" "m"

/-- The kilogram - SI unit of mass. -/
def kilogram : Unit Mass := Unit.siBase "kilogram" "kg"

/-- The second - SI unit of time. -/
def second : Unit Time := Unit.siBase "second" "s"

/-- The ampere - SI unit of electric current. -/
def ampere : Unit Current := Unit.siBase "ampere" "A"

/-- The kelvin - SI unit of thermodynamic temperature. -/
def kelvin : Unit Temperature := Unit.siBase "kelvin" "K"

/-- The mole - SI unit of amount of substance. -/
def mole : Unit Amount := Unit.siBase "mole" "mol"

/-- The candela - SI unit of luminous intensity. -/
def candela : Unit Luminosity := Unit.siBase "candela" "cd"

/-! ## SI Prefixes -/

/-- Yotta (10²⁴) -/
def yotta {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "yotta" "Y" 1e24
/-- Zetta (10²¹) -/
def zetta {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "zetta" "Z" 1e21
/-- Exa (10¹⁸) -/
def exa {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "exa" "E" 1e18
/-- Peta (10¹⁵) -/
def peta {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "peta" "P" 1e15
/-- Tera (10¹²) -/
def tera {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "tera" "T" 1e12
/-- Giga (10⁹) -/
def giga {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "giga" "G" 1e9
/-- Mega (10⁶) -/
def mega {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "mega" "M" 1e6
/-- Kilo (10³) -/
def kilo {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "kilo" "k" 1e3
/-- Hecto (10²) -/
def hecto {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "hecto" "h" 1e2
/-- Deca (10¹) -/
def deca {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "deca" "da" 1e1

/-- Deci (10⁻¹) -/
def deci {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "deci" "d" 1e-1
/-- Centi (10⁻²) -/
def centi {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "centi" "c" 1e-2
/-- Milli (10⁻³) -/
def milli {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "milli" "m" 1e-3
/-- Micro (10⁻⁶) -/
def micro {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "micro" "μ" 1e-6
/-- Nano (10⁻⁹) -/
def nano {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "nano" "n" 1e-9
/-- Pico (10⁻¹²) -/
def pico {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "pico" "p" 1e-12
/-- Femto (10⁻¹⁵) -/
def femto {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "femto" "f" 1e-15
/-- Atto (10⁻¹⁸) -/
def atto {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "atto" "a" 1e-18
/-- Zepto (10⁻²¹) -/
def zepto {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "zepto" "z" 1e-21
/-- Yocto (10⁻²⁴) -/
def yocto {d : Dimension} (u : Unit d) : Unit d := u.withPrefix "yocto" "y" 1e-24

/-! ## Common Length Units -/

def kilometer : Unit Length := kilo meter
def centimeter : Unit Length := centi meter
def millimeter : Unit Length := milli meter
def micrometer : Unit Length := micro meter
def nanometer : Unit Length := nano meter

/-! ## Common Mass Units -/

def gram : Unit Mass := Unit.scale "gram" "g" 0.001
def milligram : Unit Mass := milli gram
def microgram : Unit Mass := micro gram
def tonne : Unit Mass := Unit.scale "tonne" "t" 1000.0

/-! ## Common Time Units -/

def millisecond : Unit Time := milli second
def microsecond : Unit Time := micro second
def nanosecond : Unit Time := nano second

/-! ## SI Derived Units -/

/-- Hertz - frequency (1/s). -/
def hertz : Unit Frequency := Unit.siBase "hertz" "Hz"

/-- Newton - force (kg·m/s²). -/
def newton : Unit Force := Unit.siBase "newton" "N"

/-- Joule - energy (kg·m²/s²). -/
def joule : Unit Energy := Unit.siBase "joule" "J"

/-- Watt - power (kg·m²/s³). -/
def watt : Unit Power := Unit.siBase "watt" "W"

/-- Pascal - pressure (kg/(m·s²)). -/
def pascal : Unit Pressure := Unit.siBase "pascal" "Pa"

/-- Coulomb - electric charge (A·s). -/
def coulomb : Unit Charge := Unit.siBase "coulomb" "C"

/-- Volt - voltage (kg·m²/(A·s³)). -/
def volt : Unit Voltage := Unit.siBase "volt" "V"

/-- Ohm - resistance (kg·m²/(A²·s³)). -/
def ohm : Unit Resistance := Unit.siBase "ohm" "Ω"

/-- Farad - capacitance (A²·s⁴/(kg·m²)). -/
def farad : Unit Capacitance := Unit.siBase "farad" "F"

/-- Henry - inductance (kg·m²/(A²·s²)). -/
def henry : Unit Inductance := Unit.siBase "henry" "H"

/-- Weber - magnetic flux (kg·m²/(A·s²)). -/
def weber : Unit MagneticFlux := Unit.siBase "weber" "Wb"

/-- Tesla - magnetic field (kg/(A·s²)). -/
def tesla : Unit MagneticField := Unit.siBase "tesla" "T"

/-! ## Common Derived Unit Multiples -/

def kilojoule : Unit Energy := kilo joule
def megajoule : Unit Energy := mega joule
def gigajoule : Unit Energy := giga joule

def kilowatt : Unit Power := kilo watt
def megawatt : Unit Power := mega watt
def gigawatt : Unit Power := giga watt

def kilopascal : Unit Pressure := kilo pascal
def megapascal : Unit Pressure := mega pascal
def gigapascal : Unit Pressure := giga pascal

def millivolt : Unit Voltage := milli volt
def kilovolt : Unit Voltage := kilo volt

def milliampere : Unit Current := milli ampere
def microampere : Unit Current := micro ampere

def kilonewton : Unit Force := kilo newton
def meganewton : Unit Force := mega newton

def kilohertz : Unit Frequency := kilo hertz
def megahertz : Unit Frequency := mega hertz
def gigahertz : Unit Frequency := giga hertz

/-! ## Area and Volume -/

def squareMeter : Unit Area := Unit.siBase "square meter" "m²"
def squareKilometer : Unit Area := Unit.scale "square kilometer" "km²" 1e6
def squareCentimeter : Unit Area := Unit.scale "square centimeter" "cm²" 1e-4
def squareMillimeter : Unit Area := Unit.scale "square millimeter" "mm²" 1e-6

def cubicMeter : Unit Volume := Unit.siBase "cubic meter" "m³"
def liter : Unit Volume := Unit.scale "liter" "L" 0.001
def milliliter : Unit Volume := Unit.scale "milliliter" "mL" 1e-6
def cubicCentimeter : Unit Volume := Unit.scale "cubic centimeter" "cm³" 1e-6

/-! ## Velocity and Acceleration -/

def meterPerSecond : Unit Velocity := Unit.siBase "meter per second" "m/s"
def kilometerPerHour : Unit Velocity := Unit.scale "kilometer per hour" "km/h" (1000.0 / 3600.0)

def meterPerSecondSquared : Unit Acceleration := Unit.siBase "meter per second squared" "m/s²"

/-! ## Aliases for Convenience -/

abbrev m := meter
abbrev km := kilometer
abbrev cm := centimeter
abbrev mm := millimeter

abbrev kg := kilogram
abbrev g := gram
abbrev mg := milligram

abbrev s := second
abbrev ms := millisecond

abbrev N := newton
abbrev kN := kilonewton

abbrev J := joule
abbrev kJ := kilojoule

abbrev W := watt
abbrev kW := kilowatt
abbrev MW := megawatt

abbrev Pa := pascal
abbrev kPa := kilopascal
abbrev MPa := megapascal

abbrev V := volt
abbrev A := ampere

abbrev Hz := hertz
abbrev kHz := kilohertz
abbrev MHz := megahertz
abbrev GHz := gigahertz

abbrev L := liter
abbrev mL := milliliter

end Measures.Units.SI
