# Consistent Error Handling Pattern

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

`deleteFile` always returns `(.ok ())` even on error, while other functions return errors. This inconsistency could be confusing.

## Affected Files

- `Cellar/IO.lean`, lines 55-62

## Action Required

Either:
1. Document this design decision clearly
2. Add a separate `deleteFileIfExists` function
3. Return the actual error but provide a helper that ignores errors
