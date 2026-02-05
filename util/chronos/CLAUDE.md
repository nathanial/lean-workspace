# CLAUDE.md - chronos

## Overview

Wall clock time library for Lean 4 with nanosecond precision. Provides access to system time via POSIX FFI.

## Build Commands

```bash
lake build           # Build library
lake test            # Run tests
lake exe chronos_demo  # Run demo
```

## Architecture

### Core Types

- `Timestamp` - Unix timestamp with nanosecond precision (seconds + nanoseconds since epoch)
- `DateTime` - Broken-down date/time components (year, month, day, hour, minute, second, nanosecond)

### FFI

Uses POSIX time functions via C FFI:
- `clock_gettime(CLOCK_REALTIME)` - High-resolution wall clock
- `gmtime_r()` / `localtime_r()` - Break down to UTC/local components
- `timegm()` - Convert UTC components back to timestamp

### File Structure

```
Chronos/
├── Timestamp.lean   # Timestamp type and now function
└── DateTime.lean    # DateTime type and conversions
ffi/
└── chronos_ffi.c    # C implementation
```

## Dependencies

- **crucible** - Test framework
- No external system libraries (POSIX time is in libc)
