# Type-Safe Method Paths

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Method paths are passed as raw strings (e.g., `"/package.Service/Method"`), with no compile-time validation.

## Rationale
Add a `MethodPath` newtype with a smart constructor that validates the format, and potentially macros for compile-time validation.

Catch typos and malformed paths at compile time.

## Affected Files
- New: `Legate/Method.lean`
- `Legate/Call.lean`, `Legate/Stream.lean` - use `MethodPath` type
