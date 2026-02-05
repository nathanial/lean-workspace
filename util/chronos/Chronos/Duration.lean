/-
  Chronos.Duration
  Time span representation with nanosecond precision.
-/

import Lean.Data.Json

namespace Chronos

/-- A duration representing a time span with nanosecond precision.
    Positive values represent forward time, negative values represent backward time. -/
structure Duration where
  /-- Total nanoseconds. Can be negative for backward time spans. -/
  nanoseconds : Int
  deriving Repr, BEq, Inhabited, DecidableEq

namespace Duration

-- ============================================================================
-- Constants
-- ============================================================================

private def nanosPerMillisecond : Int := 1000000
private def nanosPerSecond : Int := 1000000000
private def nanosPerMinute : Int := nanosPerSecond * 60
private def nanosPerHour : Int := nanosPerMinute * 60
private def nanosPerDay : Int := nanosPerHour * 24

-- ============================================================================
-- Constructors
-- ============================================================================

/-- Zero duration. -/
def zero : Duration := { nanoseconds := 0 }

/-- Create a duration from nanoseconds. -/
def fromNanoseconds (ns : Int) : Duration := { nanoseconds := ns }

/-- Create a duration from milliseconds. -/
def fromMilliseconds (ms : Int) : Duration :=
  { nanoseconds := ms * nanosPerMillisecond }

/-- Create a duration from seconds. -/
def fromSeconds (secs : Int) : Duration :=
  { nanoseconds := secs * nanosPerSecond }

/-- Create a duration from minutes. -/
def fromMinutes (mins : Int) : Duration :=
  { nanoseconds := mins * nanosPerMinute }

/-- Create a duration from hours. -/
def fromHours (hours : Int) : Duration :=
  { nanoseconds := hours * nanosPerHour }

/-- Create a duration from days. -/
def fromDays (days : Int) : Duration :=
  { nanoseconds := days * nanosPerDay }

-- ============================================================================
-- Extractors
-- ============================================================================

/-- Total nanoseconds. -/
def toNanoseconds (d : Duration) : Int := d.nanoseconds

/-- Total milliseconds (truncated toward zero). -/
def toMilliseconds (d : Duration) : Int := d.nanoseconds / nanosPerMillisecond

/-- Total seconds (truncated toward zero). -/
def toSeconds (d : Duration) : Int := d.nanoseconds / nanosPerSecond

/-- Total minutes (truncated toward zero). -/
def toMinutes (d : Duration) : Int := d.nanoseconds / nanosPerMinute

/-- Total hours (truncated toward zero). -/
def toHours (d : Duration) : Int := d.nanoseconds / nanosPerHour

/-- Total days (truncated toward zero). -/
def toDays (d : Duration) : Int := d.nanoseconds / nanosPerDay

/-- Convert to floating-point seconds. May lose precision for very large durations. -/
def toFloat (d : Duration) : Float :=
  Float.ofInt d.nanoseconds / 1e9

-- ============================================================================
-- Arithmetic
-- ============================================================================

/-- Add two durations. -/
def add (a b : Duration) : Duration :=
  { nanoseconds := a.nanoseconds + b.nanoseconds }

/-- Subtract two durations. -/
def sub (a b : Duration) : Duration :=
  { nanoseconds := a.nanoseconds - b.nanoseconds }

/-- Negate a duration. -/
def neg (d : Duration) : Duration :=
  { nanoseconds := -d.nanoseconds }

/-- Absolute value of a duration. -/
def abs (d : Duration) : Duration :=
  { nanoseconds := d.nanoseconds.natAbs }

/-- Multiply a duration by a scalar. -/
def mul (d : Duration) (n : Int) : Duration :=
  { nanoseconds := d.nanoseconds * n }

/-- Divide a duration by a scalar (truncated toward zero). -/
def div (d : Duration) (n : Int) : Duration :=
  { nanoseconds := d.nanoseconds / n }

instance : Add Duration where add := add
instance : Sub Duration where sub := sub
instance : Neg Duration where neg := neg
instance : HMul Duration Int Duration where hMul := mul
instance : HMul Int Duration Duration where hMul n d := mul d n
instance : HMul Duration Nat Duration where hMul d n := mul d n
instance : HMul Nat Duration Duration where hMul n d := mul d n
instance : HDiv Duration Int Duration where hDiv := div
instance : HDiv Duration Nat Duration where hDiv d n := div d n

-- ============================================================================
-- Comparison
-- ============================================================================

instance : Ord Duration where
  compare a b := compare a.nanoseconds b.nanoseconds

instance : LT Duration where
  lt a b := a.nanoseconds < b.nanoseconds

instance : LE Duration where
  le a b := a.nanoseconds ≤ b.nanoseconds

instance (a b : Duration) : Decidable (a < b) := Int.decLt a.nanoseconds b.nanoseconds
instance (a b : Duration) : Decidable (a ≤ b) := Int.decLe a.nanoseconds b.nanoseconds

instance : Hashable Duration where
  hash d := hash d.nanoseconds

/-- Check if the duration is zero. -/
def isZero (d : Duration) : Bool := d.nanoseconds == 0

/-- Check if the duration is positive. -/
def isPositive (d : Duration) : Bool := d.nanoseconds > 0

/-- Check if the duration is negative. -/
def isNegative (d : Duration) : Bool := d.nanoseconds < 0

-- ============================================================================
-- Formatting
-- ============================================================================

/-- Extract components: (days, hours, minutes, seconds, nanoseconds).
    All components are non-negative; use `isNegative` to check sign. -/
def toComponents (d : Duration) : Nat × Nat × Nat × Nat × Nat :=
  let absNanos := d.nanoseconds.natAbs
  let days := absNanos / nanosPerDay.toNat
  let rem := absNanos % nanosPerDay.toNat
  let hours := rem / nanosPerHour.toNat
  let rem := rem % nanosPerHour.toNat
  let mins := rem / nanosPerMinute.toNat
  let rem := rem % nanosPerMinute.toNat
  let secs := rem / nanosPerSecond.toNat
  let nanos := rem % nanosPerSecond.toNat
  (days, hours, mins, secs, nanos)

/-- Format as a human-readable string like "2d 3h 30m 15s".
    Negative durations are prefixed with "-". -/
def toHumanString (d : Duration) : String :=
  if d.isZero then "0s"
  else
    let (days, hours, mins, secs, _) := d.toComponents
    let sign := if d.isNegative then "-" else ""
    let parts := #[
      if days > 0 then some s!"{days}d" else none,
      if hours > 0 then some s!"{hours}h" else none,
      if mins > 0 then some s!"{mins}m" else none,
      if secs > 0 then some s!"{secs}s" else none
    ].filterMap id
    -- If all parts are zero (sub-second duration), show milliseconds or nanoseconds
    if parts.isEmpty then
      let ms := d.nanoseconds.natAbs / nanosPerMillisecond.toNat
      if ms > 0 then sign ++ s!"{ms}ms"
      else sign ++ s!"{d.nanoseconds.natAbs}ns"
    else
      sign ++ String.intercalate " " parts.toList

/-- Format as ISO 8601 duration: "P[n]DT[n]H[n]M[n]S" -/
def toIso8601 (d : Duration) : String :=
  let (days, hours, mins, secs, nanos) := d.toComponents
  let sign := if d.isNegative then "-" else ""
  let datePart := if days > 0 then s!"{days}D" else ""
  let timeParts := String.join [
    if hours > 0 then s!"{hours}H" else "",
    if mins > 0 then s!"{mins}M" else "",
    if secs > 0 || nanos > 0 || (days == 0 && hours == 0 && mins == 0) then
      if nanos > 0 then
        let fracStr := toString nanos
        let padded := String.ofList (List.replicate (9 - fracStr.length) '0') ++ fracStr
        -- Trim trailing zeros
        let trimmed := padded.dropRightWhile (· == '0')
        s!"{secs}.{trimmed}S"
      else s!"{secs}S"
    else ""
  ]
  let timePart := if timeParts.isEmpty then "" else "T" ++ timeParts
  sign ++ "P" ++ datePart ++ timePart

instance : ToString Duration where
  toString := toHumanString

-- ============================================================================
-- JSON Serialization
-- ============================================================================

instance : Lean.ToJson Duration where
  toJson d := Lean.Json.num (Lean.JsonNumber.fromInt d.nanoseconds)

instance : Lean.FromJson Duration where
  fromJson? j := do
    let n ← j.getInt?
    return { nanoseconds := n }

end Duration

end Chronos
