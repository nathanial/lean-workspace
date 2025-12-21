# Improve Error Messages in FFI

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some FFI error messages are generic (e.g., "Write failed", "Failed to start call").

## Rationale
Include more context in error messages (method name, stream state, gRPC status details).

Easier debugging of gRPC issues.

## Affected Files
- `ffi/src/legate_ffi.cpp` - enhance error message construction
