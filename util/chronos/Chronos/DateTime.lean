/-
  Chronos.DateTime
  Broken-down date/time components.
-/

import Chronos.Timestamp
import Chronos.Timezone

namespace Chronos

/-- Broken-down date/time with nanosecond precision.
    Represents a calendar date and time of day. -/
structure DateTime where
  /-- Full year (e.g., 2025). Can be negative for BCE dates. -/
  year : Int32
  /-- Month of year [1, 12]. -/
  month : UInt8
  /-- Day of month [1, 31]. -/
  day : UInt8
  /-- Hour of day [0, 23]. -/
  hour : UInt8
  /-- Minute of hour [0, 59]. -/
  minute : UInt8
  /-- Second of minute [0, 59]. Note: leap seconds not supported. -/
  second : UInt8
  /-- Nanosecond of second [0, 999999999]. -/
  nanosecond : UInt32
  deriving Repr, BEq, Inhabited, DecidableEq

namespace DateTime

-- ============================================================================
-- FFI declarations
-- ============================================================================

/-- Raw FFI return type: nested tuple of DateTime fields -/
private abbrev DateTimeTuple :=
  Int32 × UInt8 × UInt8 × UInt8 × UInt8 × UInt8 × UInt32

/-- Raw FFI: Convert timestamp to UTC date/time components. -/
@[extern "chronos_to_utc"]
private opaque toUtcFFI (seconds : Int) (nanos : UInt32) : IO DateTimeTuple

/-- Raw FFI: Convert timestamp to local date/time components. -/
@[extern "chronos_to_local"]
private opaque toLocalFFI (seconds : Int) (nanos : UInt32) : IO DateTimeTuple

/-- Raw FFI: Convert UTC date/time components to timestamp. -/
@[extern "chronos_from_utc"]
private opaque fromUtcFFI
  (year : Int32) (month : UInt8) (day : UInt8)
  (hour : UInt8) (minute : UInt8) (second : UInt8)
  (nanosecond : UInt32) : IO (Int × UInt32)

/-- Raw FFI: Get current timezone offset in seconds. -/
@[extern "chronos_get_timezone_offset"]
private opaque getTimezoneOffsetFFI : IO Int32

-- ============================================================================
-- Tuple conversion helpers
-- ============================================================================

private def fromTuple (t : DateTimeTuple) : DateTime :=
  let (year, month, day, hour, minute, second, nanosecond) := t
  { year, month, day, hour, minute, second, nanosecond }

-- ============================================================================
-- Public API: Conversion from Timestamp
-- ============================================================================

/-- Convert a timestamp to UTC date/time. -/
def fromTimestampUtc (ts : Timestamp) : IO DateTime := do
  let tuple ← toUtcFFI ts.seconds ts.nanoseconds
  return fromTuple tuple

/-- Convert a timestamp to local date/time. -/
def fromTimestampLocal (ts : Timestamp) : IO DateTime := do
  let tuple ← toLocalFFI ts.seconds ts.nanoseconds
  return fromTuple tuple

/-- Convert a UTC date/time back to a timestamp. -/
def toTimestamp (dt : DateTime) : IO Timestamp := do
  let (secs, nanos) ← fromUtcFFI dt.year dt.month dt.day
                                  dt.hour dt.minute dt.second dt.nanosecond
  return { seconds := secs, nanoseconds := nanos }

-- ============================================================================
-- Public API: Current time
-- ============================================================================

/-- Get the current UTC date/time. -/
def nowUtc : IO DateTime := do
  let ts ← Timestamp.now
  fromTimestampUtc ts

/-- Get the current local date/time. -/
def nowLocal : IO DateTime := do
  let ts ← Timestamp.now
  fromTimestampLocal ts

/-- Get the current timezone offset in seconds (local - UTC).
    Positive for east of UTC, negative for west. -/
def getTimezoneOffset : IO Int32 :=
  getTimezoneOffsetFFI

-- ============================================================================
-- EIO versions (explicit error handling)
-- ============================================================================

/-- Convert a timestamp to UTC date/time (EIO version). -/
def fromTimestampUtcE (ts : Timestamp) : ChronosM DateTime :=
  ChronosM.liftIO (fromTimestampUtc ts) fun _ => ChronosError.conversionFailed "gmtime_r failed"

/-- Convert a timestamp to local date/time (EIO version). -/
def fromTimestampLocalE (ts : Timestamp) : ChronosM DateTime :=
  ChronosM.liftIO (fromTimestampLocal ts) fun _ => ChronosError.conversionFailed "localtime_r failed"

/-- Convert a UTC date/time back to a timestamp (EIO version). -/
def toTimestampE (dt : DateTime) : ChronosM Timestamp :=
  ChronosM.liftIO (toTimestamp dt) fun _ => ChronosError.timestampFailed "timegm failed"

/-- Get the current UTC date/time (EIO version). -/
def nowUtcE : ChronosM DateTime := do
  let ts ← Timestamp.nowE
  fromTimestampUtcE ts

/-- Get the current local date/time (EIO version). -/
def nowLocalE : ChronosM DateTime := do
  let ts ← Timestamp.nowE
  fromTimestampLocalE ts

-- ============================================================================
-- Timezone conversions
-- ============================================================================

/-- Raw FFI: Convert UTC timestamp to DateTime in specified timezone. -/
@[extern "chronos_timezone_to_datetime"]
private opaque toTimezoneFFI (tz : @& Timezone) (seconds : Int) (nanos : UInt32) : IO DateTimeTuple

/-- Raw FFI: Convert DateTime in specified timezone to UTC timestamp. -/
@[extern "chronos_timezone_from_datetime"]
private opaque fromTimezoneFFI (tz : @& Timezone)
  (year : Int32) (month : UInt8) (day : UInt8)
  (hour : UInt8) (minute : UInt8) (second : UInt8)
  (nanosecond : UInt32) : IO (Int × UInt32)

/-- Create a DateTime from a Timestamp in a specific timezone.

    Example:
    ```
    let ts ← Timestamp.now
    match ← Timezone.fromName "America/New_York" with
    | some tz =>
      let nyTime ← DateTime.fromTimestampInTimezone ts tz
      IO.println s!"New York: {nyTime}"
    | none => IO.println "Invalid timezone"
    ``` -/
def fromTimestampInTimezone (ts : Timestamp) (tz : Timezone) : IO DateTime := do
  let tuple ← toTimezoneFFI tz ts.seconds ts.nanoseconds
  return fromTuple tuple

/-- Convert a DateTime in a specific timezone to a UTC Timestamp.

    Use this when you have a DateTime that represents local time in a
    known timezone and need to convert it to an absolute point in time.

    Example:
    ```
    -- Create a DateTime representing 2025-07-04 14:30 in Los Angeles
    let dt : DateTime := { year := 2025, month := 7, day := 4,
                           hour := 14, minute := 30, second := 0, nanosecond := 0 }
    match ← Timezone.fromName "America/Los_Angeles" with
    | some tz =>
      let ts ← dt.toTimestampInTimezone tz
      IO.println s!"UTC timestamp: {ts.seconds}"
    | none => IO.println "Invalid timezone"
    ``` -/
def toTimestampInTimezone (dt : DateTime) (tz : Timezone) : IO Timestamp := do
  let (secs, nanos) ← fromTimezoneFFI tz dt.year dt.month dt.day
                                       dt.hour dt.minute dt.second dt.nanosecond
  return { seconds := secs, nanoseconds := nanos }

/-- Convert a UTC DateTime to another timezone.

    This assumes the input DateTime represents a time in UTC. The returned
    DateTime represents the same instant in the specified timezone.

    Example:
    ```
    let utcTime ← DateTime.nowUtc
    match ← Timezone.fromName "Europe/London" with
    | some tz =>
      let londonTime ← utcTime.inTimezone tz
      IO.println s!"London: {londonTime}"
    | none => IO.println "Invalid timezone"
    ``` -/
def inTimezone (dt : DateTime) (tz : Timezone) : IO DateTime := do
  let ts ← dt.toTimestamp
  fromTimestampInTimezone ts tz

/-- Get the current time in a specific timezone.

    Example:
    ```
    match ← Timezone.fromName "Asia/Tokyo" with
    | some tz =>
      let tokyoTime ← DateTime.nowInTimezone tz
      IO.println s!"Tokyo: {tokyoTime}"
    | none => IO.println "Invalid timezone"
    ``` -/
def nowInTimezone (tz : Timezone) : IO DateTime := do
  let ts ← Timestamp.now
  fromTimestampInTimezone ts tz

-- ============================================================================
-- Timezone EIO versions
-- ============================================================================

/-- Create a DateTime from a Timestamp in a specific timezone (EIO version). -/
def fromTimestampInTimezoneE (ts : Timestamp) (tz : Timezone) : ChronosM DateTime :=
  ChronosM.liftIO (fromTimestampInTimezone ts tz) fun _ =>
    ChronosError.timezoneConversionFailed "localtime failed"

/-- Convert a DateTime in a specific timezone to a UTC Timestamp (EIO version). -/
def toTimestampInTimezoneE (dt : DateTime) (tz : Timezone) : ChronosM Timestamp :=
  ChronosM.liftIO (toTimestampInTimezone dt tz) fun _ =>
    ChronosError.timezoneConversionFailed "mktime failed"

/-- Convert a UTC DateTime to another timezone (EIO version). -/
def inTimezoneE (dt : DateTime) (tz : Timezone) : ChronosM DateTime := do
  let ts ← toTimestampE dt
  fromTimestampInTimezoneE ts tz

/-- Get the current time in a specific timezone (EIO version). -/
def nowInTimezoneE (tz : Timezone) : ChronosM DateTime := do
  let ts ← Timestamp.nowE
  fromTimestampInTimezoneE ts tz

-- ============================================================================
-- Formatting helpers
-- ============================================================================

private def padZero2 (n : UInt8) : String :=
  let s := toString n.toNat
  if s.length == 1 then "0" ++ s else s

private def padZero4 (n : Int32) : String :=
  let s := toString n.toInt
  if n >= 0 && n < 10 then "000" ++ s
  else if n >= 0 && n < 100 then "00" ++ s
  else if n >= 0 && n < 1000 then "0" ++ s
  else s

/-- Format as ISO 8601 date: YYYY-MM-DD -/
def toDateString (dt : DateTime) : String :=
  s!"{padZero4 dt.year}-{padZero2 dt.month}-{padZero2 dt.day}"

/-- Format as ISO 8601 time: HH:MM:SS -/
def toTimeString (dt : DateTime) : String :=
  s!"{padZero2 dt.hour}:{padZero2 dt.minute}:{padZero2 dt.second}"

/-- Format as ISO 8601 date and time: YYYY-MM-DDTHH:MM:SS -/
def toIso8601 (dt : DateTime) : String :=
  s!"{dt.toDateString}T{dt.toTimeString}"

/-- Format as ISO 8601 with nanoseconds: YYYY-MM-DDTHH:MM:SS.NNNNNNNNN -/
def toIso8601Full (dt : DateTime) : String :=
  let nanoStr := toString dt.nanosecond.toNat
  let padded := String.ofList (List.replicate (9 - nanoStr.length) '0') ++ nanoStr
  s!"{dt.toIso8601}.{padded}"

instance : ToString DateTime where
  toString := toIso8601

-- ============================================================================
-- Date utilities
-- ============================================================================

/-- Check if a year is a leap year. -/
def isLeapYear (year : Int32) : Bool :=
  let y := year.toInt
  (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)

/-- Get the number of days in a month. -/
def daysInMonth (year : Int32) (month : UInt8) : UInt8 :=
  match month.toNat with
  | 1 => 31  -- January
  | 2 => if isLeapYear year then 29 else 28
  | 3 => 31  -- March
  | 4 => 30  -- April
  | 5 => 31  -- May
  | 6 => 30  -- June
  | 7 => 31  -- July
  | 8 => 31  -- August
  | 9 => 30  -- September
  | 10 => 31 -- October
  | 11 => 30 -- November
  | 12 => 31 -- December
  | _ => 0   -- Invalid month

-- ============================================================================
-- Validation
-- ============================================================================

/-- Check if a DateTime has valid field values.
    - month: 1-12
    - day: 1 to daysInMonth
    - hour: 0-23
    - minute: 0-59
    - second: 0-59
    - nanosecond: 0-999999999 -/
def isValid (dt : DateTime) : Bool :=
  dt.month >= 1 && dt.month <= 12 &&
  dt.day >= 1 && dt.day <= daysInMonth dt.year dt.month &&
  dt.hour <= 23 &&
  dt.minute <= 59 &&
  dt.second <= 59 &&
  dt.nanosecond <= 999999999

/-- Validate a DateTime, returning `some dt` if valid, `none` if invalid. -/
def validate (dt : DateTime) : Option DateTime :=
  if dt.isValid then some dt else none

/-- Smart constructor that validates all fields.
    Returns `some dt` if all fields are valid, `none` otherwise. -/
def mk? (year : Int32) (month : UInt8) (day : UInt8)
        (hour : UInt8 := 0) (minute : UInt8 := 0) (second : UInt8 := 0)
        (nanosecond : UInt32 := 0) : Option DateTime :=
  let dt : DateTime := { year, month, day, hour, minute, second, nanosecond }
  dt.validate

-- ============================================================================
-- Comparison
-- ============================================================================

instance : Ord DateTime where
  compare a b :=
    match compare a.year b.year with
    | .eq =>
      match compare a.month b.month with
      | .eq =>
        match compare a.day b.day with
        | .eq =>
          match compare a.hour b.hour with
          | .eq =>
            match compare a.minute b.minute with
            | .eq =>
              match compare a.second b.second with
              | .eq => compare a.nanosecond b.nanosecond
              | other => other
            | other => other
          | other => other
        | other => other
      | other => other
    | other => other

instance : LT DateTime where
  lt a b := compare a b == .lt

instance : LE DateTime where
  le a b := compare a b != .gt

instance (a b : DateTime) : Decidable (a < b) :=
  if h : compare a b == .lt then isTrue h else isFalse h

instance (a b : DateTime) : Decidable (a ≤ b) :=
  if h : compare a b != .gt then isTrue h else isFalse h

instance : Hashable DateTime where
  hash dt :=
    let h1 := mixHash (hash dt.year) (hash dt.month)
    let h2 := mixHash h1 (hash dt.day)
    let h3 := mixHash h2 (hash dt.hour)
    let h4 := mixHash h3 (hash dt.minute)
    let h5 := mixHash h4 (hash dt.second)
    mixHash h5 (hash dt.nanosecond)

-- ============================================================================
-- Weekday
-- ============================================================================

/-- Days of the week. -/
inductive Weekday where
  | sunday
  | monday
  | tuesday
  | wednesday
  | thursday
  | friday
  | saturday
  deriving Repr, BEq, Inhabited, DecidableEq

namespace Weekday

/-- Convert weekday to numeric value (0 = Sunday, 6 = Saturday). -/
def toNat : Weekday → Nat
  | sunday    => 0
  | monday    => 1
  | tuesday   => 2
  | wednesday => 3
  | thursday  => 4
  | friday    => 5
  | saturday  => 6

/-- Convert numeric value to weekday (0 = Sunday, 6 = Saturday). -/
def fromNat : Nat → Weekday
  | 0 => sunday
  | 1 => monday
  | 2 => tuesday
  | 3 => wednesday
  | 4 => thursday
  | 5 => friday
  | _ => saturday

/-- Short name (e.g., "Mon", "Tue"). -/
def toShortString : Weekday → String
  | sunday    => "Sun"
  | monday    => "Mon"
  | tuesday   => "Tue"
  | wednesday => "Wed"
  | thursday  => "Thu"
  | friday    => "Fri"
  | saturday  => "Sat"

/-- Full name (e.g., "Monday", "Tuesday"). -/
def toLongString : Weekday → String
  | sunday    => "Sunday"
  | monday    => "Monday"
  | tuesday   => "Tuesday"
  | wednesday => "Wednesday"
  | thursday  => "Thursday"
  | friday    => "Friday"
  | saturday  => "Saturday"

instance : ToString Weekday := ⟨Weekday.toLongString⟩

/-- Check if this is a weekend day (Saturday or Sunday). -/
def isWeekend : Weekday → Bool
  | saturday => true
  | sunday   => true
  | _        => false

/-- Check if this is a weekday (Monday through Friday). -/
def isWeekday (w : Weekday) : Bool := !w.isWeekend

instance : Hashable Weekday where
  hash w := hash w.toNat

end Weekday

-- ============================================================================
-- Day of Week / Day of Year
-- ============================================================================

/-- Raw FFI: Get weekday (0-6) from timestamp. -/
@[extern "chronos_weekday"]
private opaque weekdayFFI (seconds : Int) : IO UInt8

/-- Raw FFI: Get day of year (1-366) from timestamp. -/
@[extern "chronos_day_of_year"]
private opaque dayOfYearFFI (seconds : Int) : IO UInt16

/-- Get the day of the week for this DateTime. -/
def weekday (dt : DateTime) : IO Weekday := do
  let ts ← dt.toTimestamp
  let wday ← weekdayFFI ts.seconds
  return Weekday.fromNat wday.toNat

/-- Check if this DateTime falls on a weekend. -/
def isWeekend (dt : DateTime) : IO Bool := do
  let w ← dt.weekday
  return w.isWeekend

/-- Check if this DateTime falls on a weekday. -/
def isWeekday (dt : DateTime) : IO Bool := do
  let w ← dt.weekday
  return w.isWeekday

/-- Get the day of year (1-366) for this DateTime. -/
def dayOfYear (dt : DateTime) : IO UInt16 := do
  let ts ← dt.toTimestamp
  dayOfYearFFI ts.seconds

/-- Get the ISO week number (1-53) for this DateTime.
    Week 1 is the week containing the first Thursday of the year. -/
def weekOfYear (dt : DateTime) : IO UInt8 := do
  let doy ← dt.dayOfYear
  let w ← dt.weekday
  -- ISO week calculation: week 1 contains the first Thursday
  -- Adjust day of year by weekday to find week number
  let dowMondayBased := match w with
    | .monday    => 0
    | .tuesday   => 1
    | .wednesday => 2
    | .thursday  => 3
    | .friday    => 4
    | .saturday  => 5
    | .sunday    => 6
  -- Simple approximation: (dayOfYear + 6 - dayOfWeek) / 7
  let weekNum := (doy.toNat + 6 - dowMondayBased) / 7
  return UInt8.ofNat (max 1 weekNum)

-- ============================================================================
-- Parsing
-- ============================================================================

/-- Result type for parsing operations. -/
abbrev ParseResult (α : Type) := Except String α

/-- Helper to convert Option to Except with error message. -/
private def optionToExcept (o : Option α) (msg : String) : Except String α :=
  match o with
  | some a => .ok a
  | none => .error msg

/-- Parse exactly n decimal digits starting at position, return (value, newPos). -/
private def parseDigits (s : String) (start : Nat) (count : Nat) : Option (Nat × Nat) :=
  let data := s.toList
  if start + count > data.length then none
  else
    let chars := (List.range count).filterMap fun i => data[start + i]?
    if chars.length == count && chars.all Char.isDigit then
      let value := chars.foldl (fun acc c => acc * 10 + (c.toNat - '0'.toNat)) 0
      some (value, start + count)
    else none

/-- Expect a specific character at position, return new position. -/
private def expectChar (s : String) (pos : Nat) (c : Char) : Option Nat :=
  let data := s.toList
  match data[pos]? with
  | some ch => if ch == c then some (pos + 1) else none
  | none => none

/-- Parse fractional seconds (.NNNNNNNNN), returning (nanoseconds, newPos). -/
private def parseFractionalSeconds (s : String) (pos : Nat) : Nat × Nat :=
  let data := s.toList
  -- Read up to 9 digits iteratively
  let rec go (p : Nat) (count : Nat) (acc : Nat) : Nat × Nat :=
    if count >= 9 then (acc, p)
    else
      match data[p]? with
      | some c =>
        if c.isDigit then
          go (p + 1) (count + 1) (acc * 10 + (c.toNat - '0'.toNat))
        else
          -- Pad remaining with zeros
          let remaining := 9 - count
          (acc * (10 ^ remaining), p)
      | none =>
        -- Pad remaining with zeros
        let remaining := 9 - count
        (acc * (10 ^ remaining), p)
  termination_by (9 - count)
  go pos 0 0

/-- Parse ISO 8601 date/time string.
    Accepted formats:
    - "YYYY-MM-DD" (date only, time defaults to 00:00:00)
    - "YYYY-MM-DDTHH:MM:SS" (with 'T' separator)
    - "YYYY-MM-DD HH:MM:SS" (with space separator)
    - "YYYY-MM-DDTHH:MM:SS.NNNNNNNNN" (with fractional seconds)
    - Timezone suffixes like "Z" or "+05:00" are parsed but ignored (DateTime is timezone-naive). -/
def parseIso8601 (s : String) : ParseResult DateTime := do
  let s := s.trim
  if s.isEmpty then throw "empty input"

  -- Parse year (4 digits)
  let (year, pos) ← optionToExcept (parseDigits s 0 4) "expected 4-digit year"

  -- Parse -MM-DD
  let pos ← optionToExcept (expectChar s pos '-') "expected '-' after year"
  let (month, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit month"
  let pos ← optionToExcept (expectChar s pos '-') "expected '-' after month"
  let (day, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit day"

  -- Validate date components
  if month < 1 || month > 12 then throw s!"invalid month: {month}"
  let maxDay := daysInMonth (Int.toInt32 year) (UInt8.ofNat month)
  if day < 1 || day > maxDay.toNat then throw s!"invalid day: {day} for month {month}"

  -- Check if we have time component
  if pos >= s.length then
    -- Date only
    return { year := Int.toInt32 year, month := UInt8.ofNat month, day := UInt8.ofNat day,
             hour := 0, minute := 0, second := 0, nanosecond := 0 }

  -- Parse T or space separator
  let separator := match s.toList[pos]? with
    | some c => c
    | none => ' ' -- Will fail the check below
  if separator != 'T' && separator != ' ' then
    throw s!"expected 'T' or space after date, got '{separator}'"
  let pos := pos + 1

  -- Parse HH:MM:SS
  let (hour, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit hour"
  if hour > 23 then throw s!"invalid hour: {hour}"
  let pos ← optionToExcept (expectChar s pos ':') "expected ':' after hour"
  let (minute, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit minute"
  if minute > 59 then throw s!"invalid minute: {minute}"
  let pos ← optionToExcept (expectChar s pos ':') "expected ':' after minute"
  let (second, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit second"
  if second > 59 then throw s!"invalid second: {second}"

  -- Parse optional fractional seconds
  let (nanosecond, _pos) :=
    if s.toList[pos]? == some '.' then
      parseFractionalSeconds s (pos + 1)
    else (0, pos)

  -- Note: Timezone offset (Z, +HH:MM, -HH:MM) is ignored for now
  -- DateTime is timezone-naive; proper handling requires OffsetDateTime type

  return { year := Int.toInt32 year, month := UInt8.ofNat month, day := UInt8.ofNat day,
           hour := UInt8.ofNat hour, minute := UInt8.ofNat minute, second := UInt8.ofNat second,
           nanosecond := UInt32.ofNat nanosecond }

/-- Parse date only: "YYYY-MM-DD".
    Time components default to 00:00:00. -/
def parseDate (s : String) : ParseResult DateTime :=
  parseIso8601 s

/-- Parse time only: "HH:MM:SS" or "HH:MM:SS.NNNNNNNNN".
    Date components default to 1970-01-01 (Unix epoch). -/
def parseTime (s : String) : ParseResult DateTime := do
  let s := s.trim
  if s.length < 8 then throw "expected at least HH:MM:SS format"

  -- Parse HH:MM:SS
  let (hour, pos) ← optionToExcept (parseDigits s 0 2) "expected 2-digit hour"
  if hour > 23 then throw s!"invalid hour: {hour}"
  let pos ← optionToExcept (expectChar s pos ':') "expected ':' after hour"
  let (minute, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit minute"
  if minute > 59 then throw s!"invalid minute: {minute}"
  let pos ← optionToExcept (expectChar s pos ':') "expected ':' after minute"
  let (second, pos) ← optionToExcept (parseDigits s pos 2) "expected 2-digit second"
  if second > 59 then throw s!"invalid second: {second}"

  -- Parse optional fractional seconds
  let (nanosecond, _) :=
    if s.toList[pos]? == some '.' then
      parseFractionalSeconds s (pos + 1)
    else (0, pos)

  return { year := 1970, month := 1, day := 1,
           hour := UInt8.ofNat hour, minute := UInt8.ofNat minute, second := UInt8.ofNat second,
           nanosecond := UInt32.ofNat nanosecond }

-- ============================================================================
-- Arithmetic (Pure implementations)
-- ============================================================================

/-- Convert date to Julian Day Number (days since November 24, 4714 BC).
    Used for efficient date arithmetic. -/
private def toJulianDayNumber (dt : DateTime) : Int :=
  let y := dt.year.toInt
  let m := dt.month.toNat
  let d := dt.day.toNat
  -- Algorithm from Wikipedia: Julian day
  let a := (14 - m) / 12
  let yAdj := y + 4800 - a
  let mAdj := m + 12 * a - 3
  d + (153 * mAdj + 2) / 5 + 365 * yAdj + yAdj / 4 - yAdj / 100 + yAdj / 400 - 32045

/-- Convert Julian Day Number back to date components.
    Time components are preserved from the original DateTime. -/
private def fromJulianDayNumber (jdn : Int) (hour minute second : UInt8) (nanosecond : UInt32) : DateTime :=
  -- Inverse algorithm
  let a := jdn + 32044
  let b := (4 * a + 3) / 146097
  let c := a - 146097 * b / 4
  let d := (4 * c + 3) / 1461
  let e := c - 1461 * d / 4
  let m := (5 * e + 2) / 153
  let day := e - (153 * m + 2) / 5 + 1
  let month := m + 3 - 12 * (m / 10)
  let year := 100 * b + d - 4800 + m / 10
  { year := Int.toInt32 year, month := UInt8.ofNat month.toNat, day := UInt8.ofNat day.toNat,
    hour, minute, second, nanosecond }

/-- Add days to a DateTime (pure, no IO). -/
def addDaysPure (dt : DateTime) (days : Int) : DateTime :=
  let jdn := toJulianDayNumber dt + days
  fromJulianDayNumber jdn dt.hour dt.minute dt.second dt.nanosecond

/-- Add months to a DateTime (pure, no IO).
    If the resulting day is invalid (e.g., Jan 31 + 1 month = Feb 31),
    it is clamped to the last valid day of the month. -/
def addMonthsPure (dt : DateTime) (months : Int) : DateTime :=
  let totalMonths := dt.year.toInt * 12 + dt.month.toNat - 1 + months
  let newYear := totalMonths / 12
  let newMonthRaw := totalMonths % 12
  -- Handle negative modulo: Lean's % can return negative for negative dividends
  let newMonth := if newMonthRaw < 0 then newMonthRaw + 12 else newMonthRaw
  let newMonth := newMonth + 1  -- Convert from 0-indexed to 1-indexed
  let newYear := if newMonthRaw < 0 then newYear - 1 else newYear
  let maxDay := daysInMonth (Int.toInt32 newYear) (UInt8.ofNat newMonth.toNat)
  let clampedDay := min dt.day maxDay
  { dt with year := Int.toInt32 newYear, month := UInt8.ofNat newMonth.toNat, day := clampedDay }

/-- Add years to a DateTime (pure, no IO).
    Equivalent to adding 12 * years months. -/
def addYearsPure (dt : DateTime) (years : Int) : DateTime :=
  addMonthsPure dt (years * 12)

/-- Add hours to a DateTime, with proper day overflow (pure, no IO). -/
def addHoursPure (dt : DateTime) (hours : Int) : DateTime :=
  let totalHours : Int := dt.hour.toNat + hours
  let dayDelta := totalHours / 24
  let newHourRaw := totalHours % 24
  let (dayDelta, newHour) :=
    if newHourRaw < 0 then (dayDelta - 1, newHourRaw + 24)
    else (dayDelta, newHourRaw)
  let newDt := addDaysPure dt dayDelta
  { newDt with hour := UInt8.ofNat newHour.toNat }

/-- Add minutes to a DateTime, with proper hour/day overflow (pure, no IO). -/
def addMinutesPure (dt : DateTime) (minutes : Int) : DateTime :=
  let totalMinutes : Int := dt.minute.toNat + minutes
  let hourDelta := totalMinutes / 60
  let newMinuteRaw := totalMinutes % 60
  let (hourDelta, newMinute) :=
    if newMinuteRaw < 0 then (hourDelta - 1, newMinuteRaw + 60)
    else (hourDelta, newMinuteRaw)
  let newDt := addHoursPure dt hourDelta
  { newDt with minute := UInt8.ofNat newMinute.toNat }

/-- Add seconds to a DateTime, with proper minute/hour/day overflow (pure, no IO). -/
def addSecondsPure (dt : DateTime) (seconds : Int) : DateTime :=
  let totalSeconds : Int := dt.second.toNat + seconds
  let minuteDelta := totalSeconds / 60
  let newSecondRaw := totalSeconds % 60
  let (minuteDelta, newSecond) :=
    if newSecondRaw < 0 then (minuteDelta - 1, newSecondRaw + 60)
    else (minuteDelta, newSecondRaw)
  let newDt := addMinutesPure dt minuteDelta
  { newDt with second := UInt8.ofNat newSecond.toNat }

/-- Add a Duration to a DateTime (pure, no IO). -/
def addDurationPure (dt : DateTime) (d : Duration) : DateTime :=
  -- Convert duration to seconds and remaining nanoseconds
  let totalNanos : Int := dt.nanosecond.toNat + (d.nanoseconds % 1000000000)
  let secDelta := d.nanoseconds / 1000000000
  let (secDelta, newNano) :=
    if totalNanos < 0 then
      (secDelta - 1, totalNanos + 1000000000)
    else if totalNanos >= 1000000000 then
      (secDelta + 1, totalNanos - 1000000000)
    else
      (secDelta, totalNanos)
  let newDt := addSecondsPure dt secDelta
  { newDt with nanosecond := UInt32.ofNat newNano.toNat }

-- ============================================================================
-- Arithmetic (IO wrappers for API consistency)
-- ============================================================================

/-- Add days to a DateTime. -/
def addDays (dt : DateTime) (days : Int) : IO DateTime :=
  pure (addDaysPure dt days)

/-- Add months to a DateTime.
    If the resulting day is invalid, it is clamped to the last valid day. -/
def addMonths (dt : DateTime) (months : Int) : IO DateTime :=
  pure (addMonthsPure dt months)

/-- Add years to a DateTime. -/
def addYears (dt : DateTime) (years : Int) : IO DateTime :=
  pure (addYearsPure dt years)

/-- Add hours to a DateTime. -/
def addHours (dt : DateTime) (hours : Int) : IO DateTime :=
  pure (addHoursPure dt hours)

/-- Add minutes to a DateTime. -/
def addMinutes (dt : DateTime) (minutes : Int) : IO DateTime :=
  pure (addMinutesPure dt minutes)

/-- Add seconds to a DateTime. -/
def addSeconds (dt : DateTime) (seconds : Int) : IO DateTime :=
  pure (addSecondsPure dt seconds)

/-- Add a Duration to a DateTime. -/
def addDuration (dt : DateTime) (d : Duration) : IO DateTime :=
  pure (addDurationPure dt d)

-- ============================================================================
-- JSON Serialization
-- ============================================================================

instance : Lean.ToJson DateTime where
  toJson dt := Lean.Json.str dt.toIso8601

instance : Lean.FromJson DateTime where
  fromJson? j := do
    let s ← j.getStr?
    match parseIso8601 s with
    | .ok dt => pure dt
    | .error e => throw e

end DateTime

end Chronos
