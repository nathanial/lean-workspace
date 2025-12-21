# Standardize Test Organization

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Test file organization inconsistency - some tests are in `Tests/` root, one is in `Tests/Integration/`.

## Rationale
Either organize all tests by category (unit vs integration) or flatten to single directory.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Tests/`
- `/Users/Shared/Projects/lean-workspace/protolean/Tests/Integration/CrossValidation.lean`
