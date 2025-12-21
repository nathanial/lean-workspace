# Replace Magic Number for Unbounded Max

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
In `collectFlexItems` (Algorithm.lean line 201), unbounded max constraints use a magic number `1000000.0`.

Proposed change: Define a constant `Float.infinity` or `Length.unbounded` and use it consistently throughout the codebase.

## Rationale
Improved clarity, easier to audit for overflow issues, more idiomatic.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (lines 201-203)
