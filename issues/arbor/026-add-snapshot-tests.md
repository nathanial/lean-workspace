# Add Snapshot Tests

**Priority:** Medium
**Section:** Testing Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
ASCII rendering output is tested by checking substrings. Full output comparison would catch regressions.

Action required:
1. Add expected output files
2. Compare rendered output against snapshots
3. Provide snapshot update mechanism

## Rationale
Catches visual regressions.

## Affected Files
- `ArborTests/Main.lean`
- `ArborTests/AsciiRendererTests.lean`
