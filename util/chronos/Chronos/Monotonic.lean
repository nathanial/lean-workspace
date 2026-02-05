/-
  Chronos.Monotonic
  Monotonic clock for measuring elapsed time.

  Unlike wall clock time, monotonic time is unaffected by NTP adjustments,
  DST changes, or manual clock changes. It's ideal for measuring durations.
-/

import Chronos.Duration

namespace Chronos

/-- A monotonic timestamp for measuring elapsed time.
    Values are only meaningful relative to other monotonic timestamps
    from the same system boot. -/
structure MonotonicTime where
  /-- Seconds since an arbitrary epoch (typically system boot). -/
  seconds : Int
  /-- Additional nanoseconds [0, 999999999]. -/
  nanoseconds : UInt32
  deriving Repr, BEq, Inhabited, DecidableEq

namespace MonotonicTime

-- ============================================================================
-- FFI declarations
-- ============================================================================

/-- Raw FFI: Get current monotonic clock time as (seconds, nanoseconds) -/
@[extern "chronos_monotonic_now"]
private opaque nowFFI : IO (Int × UInt32)

-- ============================================================================
-- Public API
-- ============================================================================

/-- Get the current monotonic time.
    This clock is not affected by NTP adjustments or DST changes. -/
def now : IO MonotonicTime := do
  let (secs, nanos) ← nowFFI
  return { seconds := secs, nanoseconds := nanos }

/-- Convert to total nanoseconds. -/
def toNanoseconds (mt : MonotonicTime) : Int :=
  mt.seconds * 1000000000 + mt.nanoseconds.toNat

/-- Calculate the duration between two monotonic times (a - b). -/
def duration (a b : MonotonicTime) : Duration :=
  Duration.fromNanoseconds (a.toNanoseconds - b.toNanoseconds)

/-- Calculate the elapsed duration since a previous monotonic time. -/
def elapsed (start : MonotonicTime) : IO Duration := do
  let now ← MonotonicTime.now
  return duration now start

-- ============================================================================
-- Comparison
-- ============================================================================

instance : Ord MonotonicTime where
  compare a b :=
    match compare a.seconds b.seconds with
    | .eq => compare a.nanoseconds b.nanoseconds
    | other => other

instance : LT MonotonicTime where
  lt a b := a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds < b.nanoseconds)

instance : LE MonotonicTime where
  le a b := a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds ≤ b.nanoseconds)

instance (a b : MonotonicTime) : Decidable (a < b) :=
  inferInstanceAs (Decidable (a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds < b.nanoseconds)))

instance (a b : MonotonicTime) : Decidable (a ≤ b) :=
  inferInstanceAs (Decidable (a.seconds < b.seconds ∨ (a.seconds = b.seconds ∧ a.nanoseconds ≤ b.nanoseconds)))

end MonotonicTime

-- ============================================================================
-- Timing utilities
-- ============================================================================

/-- Time an IO action, returning the result and elapsed duration.
    Uses monotonic clock for accurate measurement. -/
def time (action : IO α) : IO (α × Duration) := do
  let start ← MonotonicTime.now
  let result ← action
  let elapsed ← start.elapsed
  return (result, elapsed)

/-- Time an IO action and return only the duration. -/
def timeOnly (action : IO α) : IO Duration := do
  let (_, elapsed) ← time action
  return elapsed

/-- Run an action N times and return the average duration. -/
def benchmark (n : Nat) (action : IO α) : IO Duration := do
  if n == 0 then return Duration.zero
  let start ← MonotonicTime.now
  for _ in [:n] do
    let _ ← action
  let totalElapsed ← start.elapsed
  return totalElapsed / n

end Chronos
