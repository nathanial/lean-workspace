# Consolidate Error Message Format

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

Error messages across different assertions have slightly different formats. Some prefix with "Expected", others with "Assertion failed:".

## Affected Files

- `Crucible/Core.lean` lines 15-66

## Action Required

Standardize error message format across all assertions for consistent output.
