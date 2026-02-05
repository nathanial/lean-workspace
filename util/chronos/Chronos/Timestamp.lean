/-
  Chronos.Timestamp
  Unix timestamp with nanosecond precision.
-/

import Chronos.Duration
import Chronos.Error

namespace Chronos

/-- Unix timestamp with nanosecond precision.
    Represents seconds since the Unix epoch (1970-01-01 00:00:00 UTC)
    plus additional nanoseconds. -/
structure Timestamp where
  /-- Seconds since Unix epoch. Can be negative for dates before 1970. -/
  seconds : Int
  /-- Additional nanoseconds [0, 999999999]. -/
  nanoseconds : UInt32
  deriving Repr, BEq, Inhabited, DecidableEq

namespace Timestamp

/-- The Unix epoch: 1970-01-01 00:00:00 UTC -/
def epoch : Timestamp := { seconds := 0, nanoseconds := 0 }

/-- One billion nanoseconds per second -/
private def nanosPerSecond : Int := 1000000000

-- ============================================================================
-- FFI declarations
-- ============================================================================

/-- Raw FFI: Get current wall clock time as (seconds, nanoseconds) -/
@[extern "chronos_now"]
private opaque nowFFI : IO (Int × UInt32)

-- ============================================================================
-- Public API
-- ============================================================================

/-- Get the current wall clock time. -/
def now : IO Timestamp := do
  let (secs, nanos) ← nowFFI
  return { seconds := secs, nanoseconds := nanos }

/-- Get the current wall clock time (EIO version with explicit error handling). -/
def nowE : ChronosM Timestamp :=
  ChronosM.liftIO now fun _ => ChronosError.clockUnavailable "clock_gettime failed"

/-- Create a timestamp from just seconds (nanoseconds = 0). -/
def fromSeconds (seconds : Int) : Timestamp :=
  { seconds, nanoseconds := 0 }

/-- Convert to total nanoseconds since epoch. -/
def toNanoseconds (ts : Timestamp) : Int :=
  ts.seconds * nanosPerSecond + ts.nanoseconds.toNat

/-- Create from total nanoseconds since epoch.
    Handles negative values correctly for pre-epoch dates. -/
def fromNanoseconds (nanos : Int) : Timestamp :=
  -- Use floor division to ensure nanoseconds is always non-negative
  let seconds := nanos.fdiv nanosPerSecond
  let remainingNanos := nanos.fmod nanosPerSecond
  { seconds, nanoseconds := remainingNanos.toNat.toUInt32 }

/-- Convert to floating-point seconds (may lose precision). -/
def toFloat (ts : Timestamp) : Float :=
  Float.ofInt ts.seconds + ts.nanoseconds.toFloat / 1e9

/-- Create from floating-point seconds. -/
def fromFloat (f : Float) : Timestamp :=
  let seconds := f.floor.toInt64.toInt
  let nanos := ((f - f.floor) * 1e9).toUInt32
  { seconds, nanoseconds := nanos }

-- ============================================================================
-- Arithmetic
-- ============================================================================

/-- Add seconds to a timestamp. -/
def addSeconds (ts : Timestamp) (secs : Int) : Timestamp :=
  { ts with seconds := ts.seconds + secs }

/-- Subtract seconds from a timestamp. -/
def subSeconds (ts : Timestamp) (secs : Int) : Timestamp :=
  { ts with seconds := ts.seconds - secs }

/-- Add nanoseconds to a timestamp (handles overflow into seconds). -/
def addNanoseconds (ts : Timestamp) (nanos : Int) : Timestamp :=
  let totalNanos := ts.toNanoseconds + nanos
  fromNanoseconds totalNanos

/-- Calculate the difference between two timestamps in nanoseconds. -/
def diff (a b : Timestamp) : Int :=
  a.toNanoseconds - b.toNanoseconds

/-- Calculate the difference between two timestamps in seconds (truncated). -/
def diffSeconds (a b : Timestamp) : Int :=
  a.seconds - b.seconds

-- ============================================================================
-- Duration Arithmetic
-- ============================================================================

/-- Add a duration to a timestamp. -/
def addDuration (ts : Timestamp) (d : Duration) : Timestamp :=
  fromNanoseconds (ts.toNanoseconds + d.nanoseconds)

/-- Subtract a duration from a timestamp. -/
def subDuration (ts : Timestamp) (d : Duration) : Timestamp :=
  fromNanoseconds (ts.toNanoseconds - d.nanoseconds)

/-- Calculate the duration between two timestamps (a - b). -/
def duration (a b : Timestamp) : Duration :=
  Duration.fromNanoseconds (a.toNanoseconds - b.toNanoseconds)

instance : HAdd Timestamp Duration Timestamp where hAdd := addDuration
instance : HSub Timestamp Duration Timestamp where hSub := subDuration

-- ============================================================================
-- Comparison
-- ============================================================================

instance : Ord Timestamp where
  compare a b :=
    match compare a.seconds b.seconds with
    | .eq => compare a.nanoseconds b.nanoseconds
    | other => other

instance : LT Timestamp where
  lt a b := a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds < b.nanoseconds)

instance : LE Timestamp where
  le a b := a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds ≤ b.nanoseconds)

instance (a b : Timestamp) : Decidable (a < b) :=
  inferInstanceAs (Decidable (a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds < b.nanoseconds)))

instance (a b : Timestamp) : Decidable (a ≤ b) :=
  inferInstanceAs (Decidable (a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds ≤ b.nanoseconds)))

instance : Hashable Timestamp where
  hash ts := mixHash (hash ts.seconds) (hash ts.nanoseconds)

-- ============================================================================
-- JSON Serialization
-- ============================================================================

instance : Lean.ToJson Timestamp where
  toJson ts := Lean.Json.mkObj [
    ("seconds", Lean.Json.num (Lean.JsonNumber.fromInt ts.seconds)),
    ("nanoseconds", Lean.Json.num (Lean.JsonNumber.fromNat ts.nanoseconds.toNat))
  ]

instance : Lean.FromJson Timestamp where
  fromJson? j := do
    let seconds ← j.getObjValAs? Int "seconds"
    let nanoseconds ← j.getObjValAs? Nat "nanoseconds"
    return { seconds, nanoseconds := nanoseconds.toUInt32 }

end Timestamp

end Chronos
