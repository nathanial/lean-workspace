# Consolidate Example Files

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The examples directory has four files (`SimpleGet.lean`, `PostJSON.lean`, `ClientTest.lean`, `MinimalTest.lean`) with overlapping functionality and inconsistent styles.

## Rationale
1. Keep `SimpleGet.lean` as the primary example
2. Merge `PostJSON.lean` functionality into a comprehensive `Examples.lean`
3. Move `MinimalTest.lean` and `ClientTest.lean` to a tests/ subdirectory or remove (redundant with test suite)

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/examples/`
