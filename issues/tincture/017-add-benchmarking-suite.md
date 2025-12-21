# Add Benchmarking Suite

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
No performance benchmarks exist.

## Rationale
Add benchmarks for:
- Color space conversions (especially Lab and OkLab which are more compute-intensive)
- Delta E calculations
- Gradient sampling
- Parsing/formatting

Identify performance regressions, guide optimization efforts.

## Affected Files
- New file: `TinctureTests/Benchmarks.lean` or similar
