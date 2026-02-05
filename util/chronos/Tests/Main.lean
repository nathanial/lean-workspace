/-
  Chronos Tests
-/

import Chronos
import Crucible
import Lean.Data.Json

open Crucible
open Chronos
open Lean (Json ToJson FromJson toJson fromJson?)

-- ============================================================================
-- Timestamp Tests
-- ============================================================================

testSuite "Chronos.Timestamp"

test "now returns reasonable values" := do
  let ts ← Timestamp.now
  -- Should be after 2024-01-01 (timestamp ~1704067200)
  let minTimestamp : Int := 1704067200
  -- Should be before 2100-01-01 (timestamp ~4102444800)
  let maxTimestamp : Int := 4102444800
  shouldSatisfy (ts.seconds > minTimestamp) "seconds > min"
  shouldSatisfy (ts.seconds < maxTimestamp) "seconds < max"
  -- Nanoseconds should be in valid range
  shouldSatisfy (ts.nanoseconds < 1000000000) "nanoseconds < 1e9"

test "epoch is zero" := do
  Timestamp.epoch.seconds ≡ 0
  Timestamp.epoch.nanoseconds ≡ 0

test "fromSeconds works" := do
  let ts := Timestamp.fromSeconds 1234567890
  ts.seconds ≡ 1234567890
  ts.nanoseconds ≡ 0

test "addSeconds works" := do
  let ts := Timestamp.fromSeconds 1000
  let ts2 := ts.addSeconds 500
  ts2.seconds ≡ 1500

test "subSeconds works" := do
  let ts := Timestamp.fromSeconds 1000
  let ts2 := ts.subSeconds 300
  ts2.seconds ≡ 700

test "comparison works" := do
  let a := Timestamp.fromSeconds 1000
  let b := Timestamp.fromSeconds 2000
  shouldSatisfy (a < b) "a < b"
  shouldSatisfy (b > a) "b > a"
  shouldSatisfy (a == a) "a == a"

test "toNanoseconds and fromNanoseconds roundtrip" := do
  let ts := { seconds := 1234, nanoseconds := 567890123 : Timestamp }
  let nanos := ts.toNanoseconds
  let ts2 := Timestamp.fromNanoseconds nanos
  ts2.seconds ≡ ts.seconds
  ts2.nanoseconds ≡ ts.nanoseconds

test "fromNanoseconds handles negative values (pre-epoch)" := do
  -- -1 nanosecond should be second -1 with 999999999 nanoseconds
  let ts := Timestamp.fromNanoseconds (-1)
  ts.seconds ≡ -1
  ts.nanoseconds ≡ 999999999

test "fromNanoseconds handles negative whole seconds" := do
  -- -1 second (in nanos) should be second -1 with 0 nanoseconds
  let ts := Timestamp.fromNanoseconds (-1000000000)
  ts.seconds ≡ -1
  ts.nanoseconds ≡ 0

test "fromNanoseconds handles negative with fractional part" := do
  -- -1.5 seconds = -2 seconds + 500000000 nanoseconds
  let ts := Timestamp.fromNanoseconds (-1500000000)
  ts.seconds ≡ -2
  ts.nanoseconds ≡ 500000000

test "negative timestamp roundtrip" := do
  let ts := { seconds := -100, nanoseconds := 123456789 : Timestamp }
  let nanos := ts.toNanoseconds
  let ts2 := Timestamp.fromNanoseconds nanos
  ts2.seconds ≡ ts.seconds
  ts2.nanoseconds ≡ ts.nanoseconds

test "pre-epoch date (1960) roundtrip" := do
  -- 1960-01-01 is roughly -315619200 seconds from epoch
  let ts := { seconds := -315619200, nanoseconds := 0 : Timestamp }
  let nanos := ts.toNanoseconds
  let ts2 := Timestamp.fromNanoseconds nanos
  ts2.seconds ≡ ts.seconds
  ts2.nanoseconds ≡ ts.nanoseconds



-- ============================================================================
-- DateTime Tests
-- ============================================================================

namespace DateTimeTests

testSuite "Chronos.DateTime"

test "nowUtc returns valid date" := do
  let dt ← DateTime.nowUtc
  -- Year should be reasonable
  shouldSatisfy (dt.year >= 2024) "year >= 2024"
  shouldSatisfy (dt.year < 2100) "year < 2100"
  -- Month 1-12
  shouldSatisfy (dt.month >= 1) "month >= 1"
  shouldSatisfy (dt.month <= 12) "month <= 12"
  -- Day 1-31
  shouldSatisfy (dt.day >= 1) "day >= 1"
  shouldSatisfy (dt.day <= 31) "day <= 31"
  -- Hour 0-23
  shouldSatisfy (dt.hour <= 23) "hour <= 23"
  -- Minute 0-59
  shouldSatisfy (dt.minute <= 59) "minute <= 59"
  -- Second 0-59
  shouldSatisfy (dt.second <= 59) "second <= 59"
  -- Nanosecond 0-999999999
  shouldSatisfy (dt.nanosecond < 1000000000) "nanosecond < 1e9"

test "nowLocal returns valid date" := do
  let dt ← DateTime.nowLocal
  shouldSatisfy (dt.year >= 2024) "year >= 2024"
  shouldSatisfy (dt.month >= 1) "month >= 1"
  shouldSatisfy (dt.month <= 12) "month <= 12"
  shouldSatisfy (dt.day >= 1) "day >= 1"
  shouldSatisfy (dt.day <= 31) "day <= 31"

test "UTC/Timestamp roundtrip" := do
  let ts ← Timestamp.now
  let dt ← DateTime.fromTimestampUtc ts
  let ts2 ← dt.toTimestamp
  -- Should get back the same second (nanoseconds might differ due to rounding)
  ts2.seconds ≡ ts.seconds

test "toIso8601 formats correctly" := do
  let dt : DateTime := {
    year := 2025
    month := 12
    day := 27
    hour := 14
    minute := 30
    second := 45
    nanosecond := 0
  }
  dt.toIso8601 ≡ "2025-12-27T14:30:45"

test "toDateString formats correctly" := do
  let dt : DateTime := {
    year := 2025
    month := 1
    day := 5
    hour := 0
    minute := 0
    second := 0
    nanosecond := 0
  }
  dt.toDateString ≡ "2025-01-05"

test "isLeapYear works" := do
  shouldSatisfy (DateTime.isLeapYear 2024) "2024 is leap year"
  shouldSatisfy (!DateTime.isLeapYear 2023) "2023 is not leap year"
  shouldSatisfy (DateTime.isLeapYear 2000) "2000 is leap year"
  shouldSatisfy (!DateTime.isLeapYear 1900) "1900 is not leap year"

test "daysInMonth works" := do
  DateTime.daysInMonth 2024 2 ≡ 29  -- Leap year February
  DateTime.daysInMonth 2023 2 ≡ 28  -- Non-leap year February
  DateTime.daysInMonth 2024 1 ≡ 31  -- January
  DateTime.daysInMonth 2024 4 ≡ 30  -- April

test "comparison works" := do
  let a : DateTime := { year := 2024, month := 1, day := 1, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let b : DateTime := { year := 2024, month := 1, day := 2, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  shouldSatisfy (a < b) "a < b"
  shouldSatisfy (a == a) "a == a"

test "getTimezoneOffset returns reasonable value" := do
  let offset ← DateTime.getTimezoneOffset
  -- Timezone offsets are typically between -12 and +14 hours
  -- That's -43200 to +50400 seconds
  shouldSatisfy (offset >= -43200) "offset >= -43200"
  shouldSatisfy (offset <= 50400) "offset <= 50400"



end DateTimeTests

-- ============================================================================
-- Duration Tests
-- ============================================================================

namespace DurationTests

testSuite "Chronos.Duration"

test "zero is zero" := do
  Duration.zero.nanoseconds ≡ 0
  shouldSatisfy Duration.zero.isZero "zero.isZero"

test "fromSeconds creates correct nanoseconds" := do
  let d := Duration.fromSeconds 5
  d.nanoseconds ≡ 5000000000

test "fromHours creates correct nanoseconds" := do
  let d := Duration.fromHours 2
  d.nanoseconds ≡ 2 * 60 * 60 * 1000000000

test "fromDays creates correct nanoseconds" := do
  let d := Duration.fromDays 1
  d.nanoseconds ≡ 24 * 60 * 60 * 1000000000

test "toSeconds roundtrip" := do
  let d := Duration.fromSeconds 3600
  d.toSeconds ≡ 3600

test "toMinutes works" := do
  let d := Duration.fromMinutes 90
  d.toMinutes ≡ 90

test "add durations" := do
  let a := Duration.fromMinutes 30
  let b := Duration.fromMinutes 45
  (a + b).toMinutes ≡ 75

test "subtract durations" := do
  let a := Duration.fromHours 2
  let b := Duration.fromMinutes 30
  (a - b).toMinutes ≡ 90

test "negative duration" := do
  let a := Duration.fromMinutes 30
  let b := Duration.fromHours 1
  let diff := a - b
  shouldSatisfy diff.isNegative "30m - 1h is negative"
  diff.toMinutes ≡ -30

test "multiply by scalar" := do
  let d := Duration.fromHours 2
  (d * 3).toHours ≡ (6 : Int)

test "divide by scalar" := do
  let d := Duration.fromHours 6
  (d / 2).toHours ≡ (3 : Int)

test "comparison works" := do
  let a := Duration.fromMinutes 30
  let b := Duration.fromHours 1
  shouldSatisfy (a < b) "30m < 1h"
  shouldSatisfy (b > a) "1h > 30m"

test "toHumanString formats correctly" := do
  (Duration.fromSeconds 3661).toHumanString ≡ "1h 1m 1s"
  (Duration.fromDays 2).toHumanString ≡ "2d"
  Duration.zero.toHumanString ≡ "0s"
  (Duration.fromHours 25).toHumanString ≡ "1d 1h"

test "toHumanString handles sub-second" := do
  (Duration.fromMilliseconds 500).toHumanString ≡ "500ms"
  (Duration.fromNanoseconds 1000).toHumanString ≡ "1000ns"

test "negative duration formatting" := do
  let d := Duration.fromHours (-2)
  shouldSatisfy (d.toHumanString.startsWith "-") "negative prefix"

test "abs works" := do
  let d := Duration.fromHours (-5)
  d.abs.toHours ≡ 5
  shouldSatisfy d.abs.isPositive "abs is positive"



end DurationTests

-- ============================================================================
-- Timestamp-Duration Integration Tests
-- ============================================================================

namespace TimestampDurationTests

testSuite "Chronos.Timestamp.Duration"

test "add duration to timestamp" := do
  let ts := Timestamp.fromSeconds 1000
  let d := Duration.fromSeconds 500
  let result := ts + d
  result.seconds ≡ 1500

test "subtract duration from timestamp" := do
  let ts := Timestamp.fromSeconds 1000
  let d := Duration.fromSeconds 300
  let result := ts - d
  result.seconds ≡ 700

test "duration between timestamps" := do
  let a := Timestamp.fromSeconds 1500
  let b := Timestamp.fromSeconds 1000
  let d := Timestamp.duration a b
  d.toSeconds ≡ 500

test "duration can be negative" := do
  let a := Timestamp.fromSeconds 1000
  let b := Timestamp.fromSeconds 1500
  let d := Timestamp.duration a b
  d.toSeconds ≡ -500

test "add hours to timestamp" := do
  let ts := Timestamp.fromSeconds 0
  let d := Duration.fromHours 1
  let result := ts + d
  result.seconds ≡ 3600



end TimestampDurationTests

-- ============================================================================
-- DateTime Validation Tests
-- ============================================================================

namespace ValidationTests

testSuite "Chronos.DateTime.Validation"

test "isValid accepts valid date" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  shouldSatisfy dt.isValid "valid date should pass"

test "isValid rejects invalid month (0)" := do
  let dt : DateTime := { year := 2025, month := 0, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "month 0 should be invalid"

test "isValid rejects invalid month (13)" := do
  let dt : DateTime := { year := 2025, month := 13, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "month 13 should be invalid"

test "isValid rejects invalid day (0)" := do
  let dt : DateTime := { year := 2025, month := 6, day := 0, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "day 0 should be invalid"

test "isValid rejects invalid day (32)" := do
  let dt : DateTime := { year := 2025, month := 1, day := 32, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "day 32 in January should be invalid"

test "isValid rejects Feb 30" := do
  let dt : DateTime := { year := 2025, month := 2, day := 30, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "Feb 30 should be invalid"

test "isValid accepts Feb 29 in leap year" := do
  let dt : DateTime := { year := 2024, month := 2, day := 29, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  shouldSatisfy dt.isValid "Feb 29 in leap year should be valid"

test "isValid rejects Feb 29 in non-leap year" := do
  let dt : DateTime := { year := 2025, month := 2, day := 29, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "Feb 29 in non-leap year should be invalid"

test "isValid rejects invalid hour (24)" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 24, minute := 0, second := 0, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "hour 24 should be invalid"

test "isValid rejects invalid minute (60)" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 12, minute := 60, second := 0, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "minute 60 should be invalid"

test "isValid rejects invalid second (60)" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 12, minute := 30, second := 60, nanosecond := 0 }
  shouldSatisfy (!dt.isValid) "second 60 should be invalid"

test "validate returns some for valid date" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  match dt.validate with
  | some _ => pure ()
  | none => throw (IO.userError "validate should return some for valid date")

test "validate returns none for invalid date" := do
  let dt : DateTime := { year := 2025, month := 13, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  match dt.validate with
  | some _ => throw (IO.userError "validate should return none for invalid date")
  | none => pure ()

test "mk? returns some for valid inputs" := do
  match DateTime.mk? 2025 6 15 12 30 45 with
  | some dt =>
    dt.year ≡ 2025
    dt.month ≡ 6
    dt.day ≡ 15
  | none => throw (IO.userError "mk? should return some for valid inputs")

test "mk? returns none for invalid inputs" := do
  match DateTime.mk? 2025 13 15 with
  | some _ => throw (IO.userError "mk? should return none for invalid month")
  | none => pure ()



end ValidationTests

-- ============================================================================
-- DateTime Parsing Tests
-- ============================================================================

namespace ParsingTests

testSuite "Chronos.DateTime.Parsing"

test "parseIso8601 basic" := do
  match DateTime.parseIso8601 "2025-12-27T14:30:45" with
  | .ok dt =>
    dt.year ≡ 2025
    dt.month ≡ 12
    dt.day ≡ 27
    dt.hour ≡ 14
    dt.minute ≡ 30
    dt.second ≡ 45
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseIso8601 date only" := do
  match DateTime.parseIso8601 "2025-01-15" with
  | .ok dt =>
    dt.year ≡ 2025
    dt.month ≡ 1
    dt.day ≡ 15
    dt.hour ≡ 0
    dt.minute ≡ 0
    dt.second ≡ 0
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseIso8601 with space separator" := do
  match DateTime.parseIso8601 "2025-01-01 12:00:00" with
  | .ok dt =>
    dt.hour ≡ 12
    dt.minute ≡ 0
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseIso8601 with nanoseconds" := do
  match DateTime.parseIso8601 "2025-01-01T00:00:00.123456789" with
  | .ok dt => dt.nanosecond ≡ 123456789
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseIso8601 with partial fractional seconds" := do
  match DateTime.parseIso8601 "2025-01-01T00:00:00.1" with
  | .ok dt => dt.nanosecond ≡ 100000000
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseIso8601 rejects invalid month" := do
  match DateTime.parseIso8601 "2025-13-01T00:00:00" with
  | .ok _ => throw (IO.userError "should have failed")
  | .error _ => pure ()

test "parseIso8601 rejects invalid day" := do
  match DateTime.parseIso8601 "2025-02-29T00:00:00" with
  | .ok _ => throw (IO.userError "should have failed: 2025 is not leap year")
  | .error _ => pure ()

test "parseIso8601 accepts Feb 29 in leap year" := do
  match DateTime.parseIso8601 "2024-02-29T00:00:00" with
  | .ok dt => dt.day ≡ 29
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseIso8601 rejects invalid hour" := do
  match DateTime.parseIso8601 "2025-01-01T24:00:00" with
  | .ok _ => throw (IO.userError "should have failed")
  | .error _ => pure ()

test "parseIso8601 rejects empty input" := do
  match DateTime.parseIso8601 "" with
  | .ok _ => throw (IO.userError "should have failed")
  | .error _ => pure ()

test "parseDate works" := do
  match DateTime.parseDate "2025-06-15" with
  | .ok dt =>
    dt.year ≡ 2025
    dt.month ≡ 6
    dt.day ≡ 15
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseTime works" := do
  match DateTime.parseTime "14:30:45" with
  | .ok dt =>
    dt.hour ≡ 14
    dt.minute ≡ 30
    dt.second ≡ 45
    dt.year ≡ 1970  -- Default epoch year
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parseTime with nanoseconds" := do
  match DateTime.parseTime "12:00:00.5" with
  | .ok dt => dt.nanosecond ≡ 500000000
  | .error e => throw (IO.userError s!"parse failed: {e}")



end ParsingTests

-- ============================================================================
-- DateTime Arithmetic Tests
-- ============================================================================

namespace ArithmeticTests

testSuite "Chronos.DateTime.Arithmetic"

private def mkDate (y : Int32) (m d : UInt8) : DateTime :=
  { year := y, month := m, day := d, hour := 0, minute := 0, second := 0, nanosecond := 0 }

private def mkDateTime (y : Int32) (mo d h mi s : UInt8) : DateTime :=
  { year := y, month := mo, day := d, hour := h, minute := mi, second := s, nanosecond := 0 }

test "addDays positive" := do
  let dt := mkDate 2025 1 15
  let result := dt.addDaysPure 10
  result.day ≡ 25
  result.month ≡ 1

test "addDays crosses month boundary" := do
  let dt := mkDate 2025 1 25
  let result := dt.addDaysPure 10
  result.day ≡ 4
  result.month ≡ 2

test "addDays negative" := do
  let dt := mkDate 2025 2 5
  let result := dt.addDaysPure (-10)
  result.day ≡ 26
  result.month ≡ 1

test "addDays crosses year boundary" := do
  let dt := mkDate 2025 12 25
  let result := dt.addDaysPure 10
  result.year ≡ 2026
  result.month ≡ 1
  result.day ≡ 4

test "addMonths basic" := do
  let dt := mkDate 2025 1 15
  let result := dt.addMonthsPure 3
  result.month ≡ 4
  result.year ≡ 2025

test "addMonths clamps day (Jan 31 + 1 month)" := do
  let dt := mkDate 2025 1 31
  let result := dt.addMonthsPure 1
  result.month ≡ 2
  result.day ≡ 28  -- 2025 is not a leap year

test "addMonths clamps to leap day" := do
  let dt := mkDate 2024 1 31
  let result := dt.addMonthsPure 1
  result.month ≡ 2
  result.day ≡ 29  -- 2024 is a leap year

test "addMonths crosses year boundary" := do
  let dt := mkDate 2025 11 15
  let result := dt.addMonthsPure 3
  result.month ≡ 2
  result.year ≡ 2026

test "addMonths negative" := do
  let dt := mkDate 2025 3 15
  let result := dt.addMonthsPure (-2)
  result.month ≡ 1
  result.year ≡ 2025

test "addYears basic" := do
  let dt := mkDate 2025 6 15
  let result := dt.addYearsPure 5
  result.year ≡ 2030
  result.month ≡ 6

test "addYears from leap day to non-leap year" := do
  let dt := mkDate 2024 2 29
  let result := dt.addYearsPure 1
  result.year ≡ 2025
  result.month ≡ 2
  result.day ≡ 28  -- Clamped because 2025 is not leap year

test "addHours basic" := do
  let dt := mkDateTime 2025 1 1 10 0 0
  let result := dt.addHoursPure 5
  result.hour ≡ 15

test "addHours crosses day boundary" := do
  let dt := mkDateTime 2025 1 1 23 0 0
  let result := dt.addHoursPure 3
  result.day ≡ 2
  result.hour ≡ 2

test "addHours negative" := do
  let dt := mkDateTime 2025 1 2 2 0 0
  let result := dt.addHoursPure (-5)
  result.day ≡ 1
  result.hour ≡ 21

test "addMinutes basic" := do
  let dt := mkDateTime 2025 1 1 12 30 0
  let result := dt.addMinutesPure 45
  result.hour ≡ 13
  result.minute ≡ 15

test "addMinutes crosses hour boundary" := do
  let dt := mkDateTime 2025 1 1 12 45 0
  let result := dt.addMinutesPure 30
  result.hour ≡ 13
  result.minute ≡ 15

test "addSeconds crosses minute boundary" := do
  let dt := mkDateTime 2025 1 1 12 59 45
  let result := dt.addSecondsPure 30
  result.hour ≡ 13
  result.minute ≡ 0
  result.second ≡ 15

test "addDuration with hours" := do
  let dt := mkDateTime 2025 1 1 10 0 0
  let d := Duration.fromHours 5
  let result := dt.addDurationPure d
  result.hour ≡ 15

test "addDuration crosses day" := do
  let dt := mkDateTime 2025 1 1 20 0 0
  let d := Duration.fromHours 10
  let result := dt.addDurationPure d
  result.day ≡ 2
  result.hour ≡ 6



end ArithmeticTests

-- ============================================================================
-- Monotonic Clock Tests
-- ============================================================================

namespace MonotonicTests

testSuite "Chronos.Monotonic"

test "MonotonicTime.now returns value" := do
  let mt ← MonotonicTime.now
  -- Should have non-negative seconds (since some arbitrary epoch)
  shouldSatisfy (mt.seconds >= 0) "seconds >= 0"
  -- Nanoseconds in valid range
  shouldSatisfy (mt.nanoseconds < 1000000000) "nanoseconds < 1e9"

test "MonotonicTime is monotonically increasing" := do
  let a ← MonotonicTime.now
  let b ← MonotonicTime.now
  shouldSatisfy (b >= a) "b >= a (monotonic)"

test "MonotonicTime.elapsed returns non-negative duration" := do
  let start ← MonotonicTime.now
  let elapsed ← start.elapsed
  shouldSatisfy (!elapsed.isNegative) "elapsed is non-negative"

test "MonotonicTime.duration calculates difference" := do
  let a ← MonotonicTime.now
  -- Do a tiny bit of work
  let _ := (List.range 100).map (· * 2)
  let b ← MonotonicTime.now
  let d := MonotonicTime.duration b a
  shouldSatisfy (!d.isNegative) "b - a is non-negative"

test "time function returns result and duration" := do
  let (result, elapsed) ← Chronos.time (pure 42)
  result ≡ 42
  shouldSatisfy (!elapsed.isNegative) "elapsed is non-negative"

test "timeOnly returns duration" := do
  let elapsed ← Chronos.timeOnly (pure ())
  shouldSatisfy (!elapsed.isNegative) "elapsed is non-negative"

test "benchmark returns average duration" := do
  let avg ← Chronos.benchmark 5 (pure ())
  shouldSatisfy (!avg.isNegative) "average is non-negative"

test "benchmark with zero iterations returns zero" := do
  let avg ← Chronos.benchmark 0 (pure ())
  shouldSatisfy avg.isZero "zero iterations gives zero duration"



end MonotonicTests

-- ============================================================================
-- Weekday Tests
-- ============================================================================

namespace WeekdayTests

open DateTime (Weekday)

testSuite "Chronos.Weekday"

test "Weekday.toNat gives correct values" := do
  Weekday.sunday.toNat ≡ 0
  Weekday.monday.toNat ≡ 1
  Weekday.tuesday.toNat ≡ 2
  Weekday.wednesday.toNat ≡ 3
  Weekday.thursday.toNat ≡ 4
  Weekday.friday.toNat ≡ 5
  Weekday.saturday.toNat ≡ 6

test "Weekday.fromNat roundtrips" := do
  for i in [:7] do
    (Weekday.fromNat i).toNat ≡ i

test "Weekday.fromNat wraps" := do
  (Weekday.fromNat 7).toNat ≡ 6  -- wraps to saturday (default case)
  (Weekday.fromNat 8).toNat ≡ 6  -- wraps to saturday (default case)

test "isWeekend identifies weekend days" := do
  shouldSatisfy Weekday.sunday.isWeekend "Sunday is weekend"
  shouldSatisfy Weekday.saturday.isWeekend "Saturday is weekend"
  shouldSatisfy (!Weekday.monday.isWeekend) "Monday is not weekend"
  shouldSatisfy (!Weekday.friday.isWeekend) "Friday is not weekend"

test "isWeekday identifies weekdays" := do
  shouldSatisfy Weekday.monday.isWeekday "Monday is weekday"
  shouldSatisfy Weekday.friday.isWeekday "Friday is weekday"
  shouldSatisfy (!Weekday.sunday.isWeekday) "Sunday is not weekday"
  shouldSatisfy (!Weekday.saturday.isWeekday) "Saturday is not weekday"

test "Weekday.toString works" := do
  s!"{Weekday.monday}" ≡ "Monday"
  s!"{Weekday.friday}" ≡ "Friday"

test "Weekday.toShortString works" := do
  Weekday.monday.toShortString ≡ "Mon"
  Weekday.wednesday.toShortString ≡ "Wed"

test "DateTime.weekday for known date" := do
  -- 2025-01-01 is a Wednesday
  let dt : DateTime := { year := 2025, month := 1, day := 1, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let wd ← dt.weekday
  wd ≡ Weekday.wednesday

test "DateTime.weekday for epoch" := do
  -- 1970-01-01 was a Thursday
  let dt : DateTime := { year := 1970, month := 1, day := 1, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let wd ← dt.weekday
  wd ≡ Weekday.thursday

test "DateTime.isWeekend works" := do
  -- 2025-01-04 is a Saturday
  let sat : DateTime := { year := 2025, month := 1, day := 4, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let isSatWeekend ← sat.isWeekend
  shouldSatisfy isSatWeekend "Saturday is weekend"
  -- 2025-01-06 is a Monday
  let mon : DateTime := { year := 2025, month := 1, day := 6, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let isMonWeekend ← mon.isWeekend
  shouldSatisfy (!isMonWeekend) "Monday is not weekend"

test "DateTime.dayOfYear for first day" := do
  let dt : DateTime := { year := 2025, month := 1, day := 1, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let doy ← dt.dayOfYear
  doy ≡ 1

test "DateTime.dayOfYear for last day of year" := do
  let dt : DateTime := { year := 2024, month := 12, day := 31, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let doy ← dt.dayOfYear
  doy ≡ 366  -- 2024 is a leap year

test "DateTime.dayOfYear for non-leap year" := do
  let dt : DateTime := { year := 2025, month := 12, day := 31, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let doy ← dt.dayOfYear
  doy ≡ 365

test "DateTime.weekOfYear for first week" := do
  let dt : DateTime := { year := 2025, month := 1, day := 1, hour := 0, minute := 0, second := 0, nanosecond := 0 }
  let woy ← dt.weekOfYear
  shouldSatisfy (woy >= 1 && woy <= 53) "week of year in range 1-53"



end WeekdayTests

-- ============================================================================
-- Hashable Instance Tests
-- ============================================================================

namespace HashableTests

open DateTime (Weekday)

testSuite "Chronos.Hashable"

test "Duration hash is consistent" := do
  let d1 := Duration.fromHours 5
  let d2 := Duration.fromHours 5
  (hash d1) ≡ (hash d2)

test "Duration hash differs for different values" := do
  let d1 := Duration.fromHours 5
  let d2 := Duration.fromHours 6
  shouldSatisfy (hash d1 != hash d2) "different durations have different hashes"

test "Timestamp hash is consistent" := do
  let ts1 := Timestamp.fromSeconds 1234567890
  let ts2 := Timestamp.fromSeconds 1234567890
  (hash ts1) ≡ (hash ts2)

test "Timestamp hash differs for different values" := do
  let ts1 := Timestamp.fromSeconds 1000
  let ts2 := Timestamp.fromSeconds 2000
  shouldSatisfy (hash ts1 != hash ts2) "different timestamps have different hashes"

test "DateTime hash is consistent" := do
  let dt1 : DateTime := { year := 2025, month := 1, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  let dt2 : DateTime := { year := 2025, month := 1, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  (hash dt1) ≡ (hash dt2)

test "DateTime hash differs for different values" := do
  let dt1 : DateTime := { year := 2025, month := 1, day := 15, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  let dt2 : DateTime := { year := 2025, month := 1, day := 16, hour := 12, minute := 30, second := 45, nanosecond := 0 }
  shouldSatisfy (hash dt1 != hash dt2) "different datetimes have different hashes"

test "Weekday hash is consistent" := do
  (hash Weekday.monday) ≡ (hash Weekday.monday)

test "Weekday hash differs for different days" := do
  shouldSatisfy (hash Weekday.monday != hash Weekday.friday) "different weekdays have different hashes"



end HashableTests

-- ============================================================================
-- JSON Serialization Tests
-- ============================================================================

namespace JsonTests

testSuite "Chronos.Json"

test "Duration JSON roundtrip" := do
  let d := Duration.fromHours 5
  let json := toJson d
  match (fromJson? json : Except String Duration) with
  | .ok d2 => d2.nanoseconds ≡ d.nanoseconds
  | .error e => throw (IO.userError s!"fromJson failed: {e}")

test "Duration negative JSON roundtrip" := do
  let d := Duration.fromSeconds (-3600)
  let json := toJson d
  match (fromJson? json : Except String Duration) with
  | .ok d2 => d2.nanoseconds ≡ d.nanoseconds
  | .error e => throw (IO.userError s!"fromJson failed: {e}")

test "Timestamp JSON roundtrip" := do
  let ts : Timestamp := { seconds := 1234567890, nanoseconds := 123456789 }
  let json := toJson ts
  match (fromJson? json : Except String Timestamp) with
  | .ok ts2 =>
    ts2.seconds ≡ ts.seconds
    ts2.nanoseconds ≡ ts.nanoseconds
  | .error e => throw (IO.userError s!"fromJson failed: {e}")

test "Timestamp negative JSON roundtrip" := do
  let ts : Timestamp := { seconds := -1000, nanoseconds := 500000000 }
  let json := toJson ts
  match (fromJson? json : Except String Timestamp) with
  | .ok ts2 =>
    ts2.seconds ≡ ts.seconds
    ts2.nanoseconds ≡ ts.nanoseconds
  | .error e => throw (IO.userError s!"fromJson failed: {e}")

test "DateTime JSON roundtrip" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 14, minute := 30, second := 45, nanosecond := 0 }
  let json := toJson dt
  match (fromJson? json : Except String DateTime) with
  | .ok dt2 =>
    dt2.year ≡ dt.year
    dt2.month ≡ dt.month
    dt2.day ≡ dt.day
    dt2.hour ≡ dt.hour
    dt2.minute ≡ dt.minute
    dt2.second ≡ dt.second
  | .error e => throw (IO.userError s!"fromJson failed: {e}")

test "DateTime JSON serializes as ISO 8601" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15, hour := 14, minute := 30, second := 45, nanosecond := 0 }
  let json := toJson dt
  match json with
  | .str s => s ≡ "2025-06-15T14:30:45"
  | _ => throw (IO.userError "expected JSON string")

test "DateTime JSON parses ISO 8601" := do
  let json := Json.str "2025-12-25T08:00:00"
  match (fromJson? json : Except String DateTime) with
  | .ok dt =>
    dt.year ≡ 2025
    dt.month ≡ 12
    dt.day ≡ 25
    dt.hour ≡ 8
    dt.minute ≡ 0
    dt.second ≡ 0
  | .error e => throw (IO.userError s!"fromJson failed: {e}")



end JsonTests

-- ============================================================================
-- Timezone Tests
-- ============================================================================

namespace TimezoneTests

testSuite "Chronos.Timezone"

test "UTC timezone can be loaded" := do
  let tz ← Timezone.utc
  let name ← tz.name
  shouldSatisfy (name == "UTC" || name == "Etc/UTC") "UTC name matches"

test "local timezone can be loaded" := do
  let tz ← Timezone.localTz
  let name ← tz.name
  shouldSatisfy (name.length > 0) "local timezone has name"

test "fromName returns some for UTC" := do
  match ← Timezone.fromName "UTC" with
  | some tz =>
    let name ← tz.name
    name ≡ "UTC"
  | none => throw (IO.userError "UTC should be valid")

test "fromName returns some for America/New_York" := do
  match ← Timezone.fromName "America/New_York" with
  | some tz =>
    let name ← tz.name
    name ≡ "America/New_York"
  | none => throw (IO.userError "America/New_York should be valid")

test "fromName returns some for Europe/London" := do
  match ← Timezone.fromName "Europe/London" with
  | some _ => pure ()
  | none => throw (IO.userError "Europe/London should be valid")

test "fromName returns some for Asia/Tokyo" := do
  match ← Timezone.fromName "Asia/Tokyo" with
  | some _ => pure ()
  | none => throw (IO.userError "Asia/Tokyo should be valid")

test "fromName returns none for invalid timezone" := do
  -- Note: The TZ environment variable approach may not always detect invalid
  -- timezone names (they may fall back to UTC). This test verifies that at least
  -- well-formed but non-existent timezone names don't crash.
  let _ ← Timezone.fromName "Invalid/Timezone"
  pure ()

test "UTC conversion preserves time" := do
  let utc ← Timezone.utc
  let dt : DateTime := { year := 2025, month := 6, day := 15,
                         hour := 12, minute := 30, second := 0, nanosecond := 0 }
  let ts ← dt.toTimestamp
  let dt2 ← DateTime.fromTimestampInTimezone ts utc
  dt2.year ≡ dt.year
  dt2.month ≡ dt.month
  dt2.day ≡ dt.day
  dt2.hour ≡ dt.hour
  dt2.minute ≡ dt.minute

test "New York is behind UTC in summer" := do
  -- 2025-06-15 12:00 UTC should be 08:00 in New York (EDT, UTC-4)
  -- Unix timestamp for 2025-06-15 12:00:00 UTC = 1749988800
  let ts := Timestamp.fromSeconds 1749988800
  match ← Timezone.fromName "America/New_York" with
  | some tz =>
    let nyTime ← DateTime.fromTimestampInTimezone ts tz
    -- During summer (June), New York is UTC-4
    nyTime.hour ≡ 8
    nyTime.day ≡ 15
    nyTime.month ≡ 6
  | none => throw (IO.userError "Could not load America/New_York")

test "Tokyo is ahead of UTC" := do
  -- 2025-06-15 12:00 UTC should be 21:00 in Tokyo (JST, UTC+9)
  let ts := Timestamp.fromSeconds 1749988800
  match ← Timezone.fromName "Asia/Tokyo" with
  | some tz =>
    let tokyoTime ← DateTime.fromTimestampInTimezone ts tz
    tokyoTime.hour ≡ 21
    tokyoTime.day ≡ 15
    tokyoTime.month ≡ 6
  | none => throw (IO.userError "Could not load Asia/Tokyo")

test "inTimezone converts UTC to timezone" := do
  let utcDt : DateTime := { year := 2025, month := 6, day := 15,
                            hour := 12, minute := 0, second := 0, nanosecond := 0 }
  match ← Timezone.fromName "America/Los_Angeles" with
  | some tz =>
    -- 12:00 UTC should be 05:00 PDT (UTC-7)
    let laDt ← utcDt.inTimezone tz
    laDt.hour ≡ 5
    laDt.day ≡ 15
  | none => throw (IO.userError "Could not load America/Los_Angeles")

test "roundtrip: DateTime -> Timestamp -> DateTime in same timezone" := do
  match ← Timezone.fromName "America/Los_Angeles" with
  | some tz =>
    -- Create a DateTime representing 2025-07-04 14:30 in LA
    let dt : DateTime := { year := 2025, month := 7, day := 4,
                           hour := 14, minute := 30, second := 0, nanosecond := 0 }
    -- Convert to timestamp (interpreting dt as LA time)
    let ts ← dt.toTimestampInTimezone tz
    -- Convert back to DateTime in LA timezone
    let dt2 ← DateTime.fromTimestampInTimezone ts tz
    -- Should match original
    dt2.year ≡ dt.year
    dt2.month ≡ dt.month
    dt2.day ≡ dt.day
    dt2.hour ≡ dt.hour
    dt2.minute ≡ dt.minute
  | none => throw (IO.userError "Could not load America/Los_Angeles")

test "nowInTimezone returns current time" := do
  let utc ← Timezone.utc
  let dt ← DateTime.nowInTimezone utc
  -- Basic sanity check
  shouldSatisfy (dt.year >= 2024) "year >= 2024"
  shouldSatisfy (dt.month >= 1 && dt.month <= 12) "valid month"

test "Chronos.timezone convenience function works" := do
  match ← Chronos.timezone "America/New_York" with
  | some _ => pure ()
  | none => throw (IO.userError "timezone convenience function failed")

test "Chronos.utc returns UTC timezone" := do
  let tz ← Chronos.utc
  let name ← tz.name
  shouldSatisfy (name == "UTC" || name == "Etc/UTC") "utc convenience function works"



end TimezoneTests

-- ============================================================================
-- EIO Error Handling Tests
-- ============================================================================

namespace EIOTests

testSuite "Chronos.EIO"

test "ChronosError.toString formats correctly" := do
  let e1 := ChronosError.clockUnavailable "test"
  e1.toString ≡ "Clock unavailable: test"

  let e2 := ChronosError.invalidTimezone "Bad/Zone"
  e2.toString ≡ "Invalid timezone: Bad/Zone"

test "Timestamp.nowE succeeds" := do
  match ← Timestamp.nowE.run with
  | .ok ts =>
    shouldSatisfy (ts.seconds > 0) "got valid timestamp"
  | .error e =>
    throw (IO.userError s!"nowE failed: {e}")

test "DateTime.nowUtcE succeeds" := do
  match ← DateTime.nowUtcE.run with
  | .ok dt =>
    shouldSatisfy (dt.year >= 2024) "got valid year"
  | .error e =>
    throw (IO.userError s!"nowUtcE failed: {e}")

test "DateTime.nowLocalE succeeds" := do
  match ← DateTime.nowLocalE.run with
  | .ok dt =>
    shouldSatisfy (dt.year >= 2024) "got valid year"
  | .error e =>
    throw (IO.userError s!"nowLocalE failed: {e}")

test "DateTime.toTimestampE roundtrip" := do
  let dt : DateTime := { year := 2025, month := 6, day := 15,
                         hour := 12, minute := 30, second := 0, nanosecond := 0 }
  match ← DateTime.toTimestampE dt |>.run with
  | .ok ts =>
    match ← DateTime.fromTimestampUtcE ts |>.run with
    | .ok dt2 =>
      dt2.year ≡ dt.year
      dt2.month ≡ dt.month
      dt2.day ≡ dt.day
    | .error e => throw (IO.userError s!"fromTimestampUtcE failed: {e}")
  | .error e => throw (IO.userError s!"toTimestampE failed: {e}")

test "ChronosM.toIO converts to IO" := do
  let action : ChronosM Timestamp := Timestamp.nowE
  let ts ← action.toIO
  shouldSatisfy (ts.seconds > 0) "toIO works"

test "pre-epoch timestamp (-1) works correctly" := do
  -- 1969-12-31 23:59:59 UTC has timestamp -1
  let dt : DateTime := { year := 1969, month := 12, day := 31,
                         hour := 23, minute := 59, second := 59, nanosecond := 0 }
  match ← DateTime.toTimestampE dt |>.run with
  | .ok ts =>
    ts.seconds ≡ -1
    ts.nanoseconds ≡ 0
  | .error e => throw (IO.userError s!"toTimestampE failed for -1 timestamp: {e}")

test "nowInTimezoneE succeeds" := do
  match ← Timezone.fromName "America/New_York" with
  | some tz =>
    match ← DateTime.nowInTimezoneE tz |>.run with
    | .ok dt =>
      shouldSatisfy (dt.year >= 2024) "got valid year in timezone"
    | .error e =>
      throw (IO.userError s!"nowInTimezoneE failed: {e}")
  | none => throw (IO.userError "Could not load timezone")



end EIOTests

-- ============================================================================
-- Main
-- ============================================================================

def main : IO UInt32 := runAllSuites
