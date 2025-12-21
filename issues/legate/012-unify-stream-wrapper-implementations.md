# Unify Stream Wrapper Implementations

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The FFI has three nearly identical stream wrapper types (`ClientStreamWrapper`, `ServerStreamWrapper`, `BidiStreamWrapper`) with duplicated fields and logic.

## Rationale
Refactor to a single parameterized `StreamWrapper<Mode>` template or use a common base class with mode-specific behavior.

Reduces code duplication (~100 lines), easier maintenance, fewer potential inconsistencies.

## Affected Files
- `ffi/src/legate_ffi.cpp` (lines ~76-98)
