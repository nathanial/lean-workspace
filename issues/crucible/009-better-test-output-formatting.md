# Better Test Output Formatting

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Improve test output with colors, progress indicators, and summary statistics.

## Rationale

Current output is minimal. Enhanced formatting could include:
- Colored pass/fail indicators (green checkmark, red X)
- Progress bar for long test runs
- Timing information per test
- Summary with total time, pass/fail counts by suite

## Affected Files

- `Crucible/Core.lean` - Enhance `runTest` and `runTests` output
- New file `Crucible/Output.lean` - Formatting utilities
