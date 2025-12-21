# Add Benchmarks

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
No performance benchmarks exist for comparing optic operations against manual alternatives.

## Rationale
Create a benchmark suite comparing:
- Optic-based access vs. direct field access
- Composed traversals vs. manual recursive functions
- Different traversal strategies (e.g., `each` vs. manual folds)

Performance visibility, regression detection.

## Affected Files
- New: `bench/` directory with benchmark code
