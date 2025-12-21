# Inconsistent Indentation in FFI.lean

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some function declarations in the `Internal` namespace use inconsistent indentation (extra spaces before `@[extern]`).

## Rationale
Normalize indentation throughout the file.

## Affected Files
- `Legate/Internal/FFI.lean` (lines 211-225, 254-311)
