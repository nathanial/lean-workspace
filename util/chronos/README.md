# Chronos

Wall clock time library for Lean 4 with nanosecond precision.

## Overview

Chronos provides access to system wall clock time via FFI to POSIX time functions. Unlike Lean's built-in monotonic time, this library gives you the actual calendar date and time.

## Installation

Add to your `lakefile.lean`:

```lean
require chronos from git "https://github.com/nathanial/chronos-lean" @ "v0.0.1"
```

## Quick Start

```lean
import Chronos

def main : IO Unit := do
  -- Get current Unix timestamp
  let ts ← Chronos.now
  IO.println s!"Unix timestamp: {ts.seconds}.{ts.nanoseconds}"

  -- Get current local date/time
  let local ← Chronos.nowLocal
  IO.println s!"Local time: {local.toIso8601}"

  -- Get current UTC date/time
  let utc ← Chronos.nowUtc
  IO.println s!"UTC time: {utc.toIso8601}"
```

## Types

### Timestamp

Unix timestamp with nanosecond precision:

```lean
structure Timestamp where
  seconds : Int        -- Seconds since Unix epoch (1970-01-01 00:00:00 UTC)
  nanoseconds : UInt32 -- Additional nanoseconds [0, 999999999]
```

### DateTime

Broken-down date/time components:

```lean
structure DateTime where
  year : Int32         -- Full year (e.g., 2025)
  month : UInt8        -- 1-12
  day : UInt8          -- 1-31
  hour : UInt8         -- 0-23
  minute : UInt8       -- 0-59
  second : UInt8       -- 0-59
  nanosecond : UInt32  -- 0-999999999
```

## API Reference

### Getting Current Time

```lean
Chronos.now : IO Timestamp           -- Current Unix timestamp
Chronos.nowUtc : IO DateTime         -- Current UTC date/time
Chronos.nowLocal : IO DateTime       -- Current local date/time
```

### Conversions

```lean
DateTime.fromTimestampUtc : Timestamp → IO DateTime
DateTime.fromTimestampLocal : Timestamp → IO DateTime
DateTime.toTimestamp : DateTime → IO Timestamp
```

### Timestamp Operations

```lean
Timestamp.fromSeconds : Int → Timestamp
Timestamp.addSeconds : Timestamp → Int → Timestamp
Timestamp.subSeconds : Timestamp → Int → Timestamp
Timestamp.addNanoseconds : Timestamp → Int → Timestamp
Timestamp.diff : Timestamp → Timestamp → Int  -- difference in nanoseconds
Timestamp.toFloat : Timestamp → Float
```

### DateTime Formatting

```lean
DateTime.toIso8601 : DateTime → String      -- "2025-12-27T14:30:45"
DateTime.toIso8601Full : DateTime → String  -- "2025-12-27T14:30:45.123456789"
DateTime.toDateString : DateTime → String   -- "2025-12-27"
DateTime.toTimeString : DateTime → String   -- "14:30:45"
```

### Date Utilities

```lean
DateTime.isLeapYear : Int32 → Bool
DateTime.daysInMonth : Int32 → UInt8 → UInt8
DateTime.getTimezoneOffset : IO Int32  -- seconds, local - UTC
```

## Build Commands

```bash
lake build              # Build library
lake test               # Run tests
lake exe chronos_demo   # Run demo
```

## Dependencies

- **crucible** - Test framework
- No external system libraries (uses POSIX libc)

## License

MIT License
