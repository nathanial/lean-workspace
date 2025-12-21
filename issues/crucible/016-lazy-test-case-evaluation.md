# Lazy Test Case Evaluation

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description

All `TestCase` structures are created at module load time.

## Proposed Change

Use thunks for the `run` field to defer test body construction until execution.

## Benefits

Potentially faster startup for large test suites.

## Affected Files

- `Crucible/Core.lean`
