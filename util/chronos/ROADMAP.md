# Roadmap

This document tracks proposed features, code improvements, and cleanup tasks for the Chronos library.

## Feature Proposals

### [Priority: High] Duration Type

**Description:** Add a `Duration` type to represent time spans with nanosecond precision, distinct from `Timestamp` which represents absolute points in time.

**Rationale:** Currently, time differences are represented as raw `Int` (nanoseconds) from `Timestamp.diff`. A dedicated `Duration` type would provide:
- Type safety (cannot accidentally mix durations and timestamps)
- Convenient constructors (`Duration.fromSeconds`, `Duration.fromMinutes`, etc.)
- Arithmetic operations between `Duration` and `Timestamp`
- Formatting (e.g., "2h 30m 15s")

**Affected Files:**
- New file: `Chronos/Duration.lean`
- `Chronos/Timestamp.lean` (add Duration-aware operations)
- `Chronos.lean` (re-export)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] DateTime Parsing

**Description:** Add parsing capabilities to construct `DateTime` from ISO 8601 strings.

**Rationale:** The library currently only formats DateTime to strings but cannot parse strings back to DateTime. This limits interoperability with external data sources (JSON APIs, config files, etc.).

**Proposed API:**
```lean
DateTime.parseIso8601 : String -> Option DateTime
DateTime.parseDate : String -> Option DateTime  -- YYYY-MM-DD
DateTime.parseTime : String -> Option DateTime  -- HH:MM:SS
```

**Affected Files:**
- `Chronos/DateTime.lean` (add parsing functions)
- `Tests/Main.lean` (add parsing tests)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] DateTime Arithmetic

**Description:** Add functions to perform calendar-aware arithmetic on DateTime values.

**Rationale:** While `Timestamp` has `addSeconds`/`subSeconds`, there are no direct operations to add days, months, or years to a `DateTime`. Users must convert to Timestamp, do arithmetic, and convert back.

**Proposed API:**
```lean
DateTime.addDays : DateTime -> Int -> IO DateTime
DateTime.addMonths : DateTime -> Int -> IO DateTime
DateTime.addYears : DateTime -> Int -> IO DateTime
DateTime.addHours : DateTime -> Int -> IO DateTime
DateTime.addMinutes : DateTime -> Int -> IO DateTime
```

**Affected Files:**
- `Chronos/DateTime.lean`
- `Tests/Main.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Monotonic Clock Support

**Description:** Add support for monotonic clocks (`CLOCK_MONOTONIC`) for measuring elapsed time intervals.

**Rationale:** Wall clock time can jump backwards (NTP adjustments, DST changes, etc.). For measuring durations within an application (benchmarks, timeouts), a monotonic clock is more appropriate.

**Proposed API:**
```lean
Chronos.Monotonic.now : IO Timestamp
Chronos.Monotonic.elapsed : Timestamp -> IO Duration
```

**Affected Files:**
- New file: `Chronos/Monotonic.lean`
- `ffi/chronos_ffi.c` (add `clock_gettime(CLOCK_MONOTONIC)`)
- `Chronos.lean` (re-export)

**Estimated Effort:** Small

**Dependencies:** Duration type

---

### [Priority: Medium] Day of Week

**Description:** Add day-of-week information to `DateTime` and provide related utilities.

**Rationale:** Common use case for calendaring and scheduling. Currently not exposed even though `struct tm` provides `tm_wday`.

**Proposed API:**
```lean
inductive Weekday where
  | sunday | monday | tuesday | wednesday | thursday | friday | saturday

DateTime.weekday : DateTime -> IO Weekday
DateTime.isWeekend : DateTime -> IO Bool
DateTime.isWeekday : DateTime -> IO Bool
```

**Affected Files:**
- `Chronos/DateTime.lean` (or new file `Chronos/Weekday.lean`)
- `ffi/chronos_ffi.c` (extend `mk_datetime_tuple` to include weekday)

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Day of Year

**Description:** Add day-of-year (1-366) and week number information.

**Rationale:** Useful for date calculations, fiscal calendars, and ISO week numbering. Available from `struct tm` (`tm_yday`).

**Proposed API:**
```lean
DateTime.dayOfYear : DateTime -> IO UInt16
DateTime.weekOfYear : DateTime -> IO UInt8
DateTime.isoWeek : DateTime -> IO (UInt16 × UInt8)  -- (year, week)
```

**Affected Files:**
- `Chronos/DateTime.lean`
- `ffi/chronos_ffi.c`

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Named Timezones

**Description:** Support for IANA timezone names (e.g., "America/New_York") beyond just UTC and local time.

**Rationale:** The current API only supports UTC and system-local time. Applications dealing with multiple timezones need the ability to convert to/from specific zones.

**Proposed API:**
```lean
structure Timezone where
  name : String

Timezone.utc : Timezone
Timezone.local : IO Timezone
Timezone.fromName : String -> Option Timezone

DateTime.inTimezone : DateTime -> Timezone -> IO DateTime
```

**Affected Files:**
- New file: `Chronos/Timezone.lean`
- `ffi/chronos_ffi.c` (use `setenv("TZ", ...)` or platform-specific APIs)

**Estimated Effort:** Large

**Dependencies:** None

**Notes:** This is complex due to platform differences. Consider optional dependency on ICU or using the IANA tzdata.

---

### [Priority: Medium] Time Measurement Utilities

**Description:** Add convenience functions for timing code execution.

**Rationale:** Common use case that currently requires manual bookkeeping.

**Proposed API:**
```lean
Chronos.time : IO a -> IO (a × Duration)
Chronos.timeIO : IO a -> IO (a × Duration)  -- alias
Chronos.benchmark : Nat -> IO a -> IO Duration  -- average over N runs
```

**Affected Files:**
- New file: `Chronos/Measure.lean`
- `Chronos.lean`

**Estimated Effort:** Small

**Dependencies:** Duration type, Monotonic clock (for accurate measurement)

---

### [Priority: Low] Sleep Functions

**Description:** Add cross-platform sleep functions with nanosecond precision.

**Rationale:** Natural companion to a time library. Currently must use platform-specific code or IO.sleep (milliseconds only).

**Proposed API:**
```lean
Chronos.sleep : Duration -> IO Unit
Chronos.sleepUntil : Timestamp -> IO Unit
```

**Affected Files:**
- New file: `Chronos/Sleep.lean`
- `ffi/chronos_ffi.c` (add `nanosleep` binding)

**Estimated Effort:** Small

**Dependencies:** Duration type

---

### [Priority: Low] Locale-Aware Formatting

**Description:** Add locale-aware date/time formatting using platform functions.

**Rationale:** Current formatting is fixed (ISO 8601). Some applications need localized formats.

**Proposed API:**
```lean
DateTime.formatLocale : DateTime -> String -> IO String
-- Pattern strings like "YYYY-MM-DD", "MMM d, yyyy", etc.
```

**Affected Files:**
- `Chronos/DateTime.lean`
- `ffi/chronos_ffi.c` (use `strftime`)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Calendar Types

**Description:** Add date-only and time-only types for cases where full DateTime is not needed.

**Rationale:** Sometimes you only care about dates (birthdays, holidays) or times (alarm clock, schedule). Separate types would be cleaner.

**Proposed Types:**
```lean
structure Date where
  year : Int32
  month : UInt8
  day : UInt8

structure Time where
  hour : UInt8
  minute : UInt8
  second : UInt8
  nanosecond : UInt32
```

**Affected Files:**
- New file: `Chronos/Date.lean`
- New file: `Chronos/Time.lean`

**Estimated Effort:** Medium

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Hashable Instances

**Current State:** `Timestamp` and `DateTime` derive `BEq` but lack `Hashable` instances.

**Proposed Change:** Add `Hashable` instances for both types to enable use in `HashMap` and `HashSet`.

**Benefits:** Enables common data structure usage patterns.

**Affected Files:**
- `Chronos/Timestamp.lean`
- `Chronos/DateTime.lean`

**Estimated Effort:** Small

---

### [Priority: High] Decidable Equality and Ordering

**Current State:** Types implement `Ord`, `LT`, `LE` but not `DecidableEq` or decidable ordering proofs.

**Proposed Change:** Add decidable instances for use in proof contexts.

**Benefits:** Enables use in dependent types and theorem proving.

**Affected Files:**
- `Chronos/Timestamp.lean`
- `Chronos/DateTime.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Pure DateTime Validation

**Current State:** `DateTime` structure accepts any field values without validation. Invalid dates like month=13 or day=32 can be constructed.

**Proposed Change:** Add a validation function and consider a validated newtype or smart constructor.

**Proposed API:**
```lean
DateTime.isValid : DateTime -> Bool
DateTime.validate : DateTime -> Option DateTime
DateTime.mk? : Int32 -> UInt8 -> UInt8 -> UInt8 -> UInt8 -> UInt8 -> UInt32 -> Option DateTime
```

**Benefits:** Catch errors early, prevent invalid states.

**Affected Files:**
- `Chronos/DateTime.lean`
- `Tests/Main.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] Error Handling Improvements

**Current State:** FFI functions can fail (e.g., `gmtime_r failed`) but return `IO` with potential exceptions. The `-1` timestamp edge case is noted as a limitation.

**Proposed Change:**
1. Use `IO (Except Error a)` or `EIO Error a` for explicit error handling
2. Handle the `-1` edge case properly by checking the errno after `timegm`

**Benefits:** More predictable error handling, better debugging.

**Affected Files:**
- `Chronos/Timestamp.lean`
- `Chronos/DateTime.lean`
- `ffi/chronos_ffi.c`

**Estimated Effort:** Medium

---

### [Priority: Medium] Negative Timestamp Handling

**Current State:** `fromNanoseconds` may not correctly handle negative timestamps (dates before 1970).

**Proposed Change:** Audit and fix modulo behavior for negative values. Add tests for pre-epoch dates.

**Benefits:** Correct behavior for historical dates.

**Affected Files:**
- `Chronos/Timestamp.lean`
- `Tests/Main.lean`

**Estimated Effort:** Small

---

### [Priority: Medium] ToJson/FromJson Instances

**Current State:** No JSON serialization support.

**Proposed Change:** Add `ToJson` and `FromJson` instances for `Timestamp` and `DateTime` (ISO 8601 strings or epoch numbers).

**Benefits:** Easy integration with web APIs and data serialization.

**Affected Files:**
- `Chronos/Timestamp.lean`
- `Chronos/DateTime.lean`
- `lakefile.lean` (add optional `Lean.Data.Json` dependency if needed)

**Estimated Effort:** Small

**Dependencies:** Consider whether to make this optional to avoid dependency bloat.

---

### [Priority: Low] Optimize Comparison Implementation

**Current State:** `DateTime.compare` uses nested pattern matching on 7 fields.

**Proposed Change:** Convert to timestamp and compare, or use lexicographic ordering on a tuple.

**Benefits:** Simpler code, potentially faster.

**Affected Files:**
- `Chronos/DateTime.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Add Numeric Type Conversions

**Current State:** Limited conversions between numeric types (e.g., `toFloat`, `fromFloat`).

**Proposed Change:** Add conversions to/from `Int64`, `UInt64`, and consider JavaScript Date compatibility (milliseconds since epoch).

**Proposed API:**
```lean
Timestamp.toMilliseconds : Timestamp -> Int
Timestamp.fromMilliseconds : Int -> Timestamp
Timestamp.toInt64 : Timestamp -> Int64  -- seconds only
```

**Benefits:** Interoperability with other systems.

**Affected Files:**
- `Chronos/Timestamp.lean`

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: Medium] FFI Code Style Consistency

**Issue:** The C FFI code uses inconsistent comment styles (C89 `/* */` and section headers).

**Location:** `ffi/chronos_ffi.c` throughout

**Action Required:** Standardize comment style to match project conventions.

**Estimated Effort:** Small

---

### [Priority: Medium] Unused nanosPerSecond Constant

**Issue:** The private constant `nanosPerSecond` is defined but never used in `Timestamp.lean`.

**Location:** `Chronos/Timestamp.lean:24`

**Action Required:** Either remove the unused constant or use it in place of the hardcoded `1000000000` values.

**Estimated Effort:** Small

---

### [Priority: Low] Test Coverage for Edge Cases

**Issue:** Tests do not cover:
- Pre-epoch dates (negative timestamps)
- Year 2038 problem scenarios (for 32-bit time_t systems)
- Leap second handling (documented as unsupported, but could test behavior)
- DST transitions
- Extreme dates (very distant past/future)

**Location:** `Tests/Main.lean`

**Action Required:** Add edge case tests.

**Estimated Effort:** Medium

---

### [Priority: Low] Portable timegm Alternative

**Issue:** `timegm()` is a BSD/GNU extension and may not be available on all platforms.

**Location:** `ffi/chronos_ffi.c:165`

**Action Required:** Add a portable fallback for platforms without `timegm`. The standard workaround involves temporarily setting `TZ=""` and calling `mktime`.

**Estimated Effort:** Small

---

### [Priority: Low] Documentation Improvements

**Issue:** Some functions lack doc comments explaining edge cases and limitations.

**Location:**
- `Timestamp.fromFloat` - does not document precision loss
- `DateTime.toTimestamp` - does not document that it expects UTC input

**Action Required:** Add comprehensive doc comments.

**Estimated Effort:** Small

---

### [Priority: Low] Int32 Year Limitation

**Issue:** `DateTime.year` is `Int32`, which limits the range of representable years. While sufficient for practical use, it differs from `Timestamp.seconds` which is `Int`.

**Location:** `Chronos/DateTime.lean:12`

**Action Required:** Document the limitation or consider using `Int` for consistency with scientific/astronomical applications. Low priority as Int32 covers years far beyond practical need.

**Estimated Effort:** Small

---

## Future Considerations

### Platform Support

- **Windows:** The current implementation uses POSIX functions. Windows support would require `GetSystemTime`, `FileTimeToSystemTime`, etc.
- **WebAssembly:** WASI provides POSIX-like APIs, but testing is needed.

### Integration Opportunities

- **Chronicle (logging):** Use Chronos timestamps for log entries instead of relying on system-provided timestamps.
- **Ledger (database):** Chronos could provide temporal data types for Ledger transactions.
- **Citadel (HTTP server):** HTTP date header formatting.

### Related Libraries

Consider how Chronos relates to:
- **Measures:** Could `Duration` be a unit-of-measure type?
- **Linalg:** Time-based interpolation and animation curves.
