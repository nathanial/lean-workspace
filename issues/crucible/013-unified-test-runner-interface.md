# Unified Test Runner Interface

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description

The `runTests` function returns `IO UInt32` where the exit code represents failure count. Projects must manually accumulate exit codes (see protolean, collimator, wisp main functions).

## Proposed Change

Return a structured `TestResults` type with pass/fail counts, timing, and provide a standard `toExitCode` method.

## Benefits

Cleaner API, better composability, enables richer reporting.

## Affected Files

- `Crucible/Core.lean`
