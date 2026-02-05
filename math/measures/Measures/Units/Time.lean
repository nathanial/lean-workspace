/-
  Measures.Units.Time

  Extended time units beyond the SI second.
-/

import Measures.Core.Unit
import Measures.Dimensions
import Measures.Units.SI

namespace Measures.Units.Time

open Measures
open Dimension

/-! ## Common Time Units -/

/-- The second (SI base unit, re-exported from SI). -/
abbrev second : Unit Time := Units.SI.second

/-- The minute (60 seconds). -/
def minute : Unit Time := Unit.scale "minute" "min" 60.0

/-- The hour (60 minutes = 3600 seconds). -/
def hour : Unit Time := Unit.scale "hour" "h" 3600.0

/-- The day (24 hours = 86400 seconds). -/
def day : Unit Time := Unit.scale "day" "d" 86400.0

/-- The week (7 days). -/
def week : Unit Time := Unit.scale "week" "wk" 604800.0

/-- The month (average, 30.44 days). -/
def month : Unit Time := Unit.scale "month" "mo" 2629746.0

/-- The year (365.25 days, Julian year). -/
def year : Unit Time := Unit.scale "year" "yr" 31557600.0

/-- The decade (10 years). -/
def decade : Unit Time := Unit.scale "decade" "dec" 315576000.0

/-- The century (100 years). -/
def century : Unit Time := Unit.scale "century" "c" 3155760000.0

/-! ## Small Time Units -/

/-- The millisecond (re-exported from SI). -/
abbrev millisecond : Unit Time := Units.SI.millisecond

/-- The microsecond (re-exported from SI). -/
abbrev microsecond : Unit Time := Units.SI.microsecond

/-- The nanosecond (re-exported from SI). -/
abbrev nanosecond : Unit Time := Units.SI.nanosecond

/-- The picosecond. -/
def picosecond : Unit Time := Unit.scale "picosecond" "ps" 1e-12

/-- The femtosecond. -/
def femtosecond : Unit Time := Unit.scale "femtosecond" "fs" 1e-15

/-! ## Scientific Time Units -/

/-- The sidereal day (23h 56m 4.0905s). -/
def siderealDay : Unit Time := Unit.scale "sidereal day" "sd" 86164.0905

/-- The sidereal year (365.25636 days). -/
def siderealYear : Unit Time := Unit.scale "sidereal year" "syr" 31558149.8

/-! ## Frequency Aliases -/

/-- Hertz (per second, re-exported from SI). -/
abbrev hertz : Unit Frequency := Units.SI.hertz

/-- Beats per minute (for music). -/
def bpm : Unit Frequency := Unit.scale "beats per minute" "bpm" (1.0 / 60.0)

/-- Revolutions per minute. -/
def rpm : Unit Frequency := Unit.scale "revolutions per minute" "rpm" (1.0 / 60.0)

/-! ## Aliases -/

abbrev s := second
abbrev ms := millisecond
abbrev us := microsecond
abbrev ns := nanosecond
abbrev min := minute
abbrev h := hour
abbrev d := day
abbrev wk := week
abbrev yr := year

end Measures.Units.Time
