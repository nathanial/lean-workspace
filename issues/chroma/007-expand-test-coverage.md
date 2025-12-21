# Expand Test Coverage

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Tests are minimal placeholder tests:
```lean
test "placeholder" :=
  ensure true "sanity check"
```

Action required:
- Add tests for `hueFromPoint` and `hueFromPosition` functions
- Add tests for `circlePoints`, `ringSegmentPoints`, `orientedRectPoints`
- Add property-based tests using Plausible (already a dependency)
- Test edge cases: zero-size picker, boundary hits, angle wraparound

## Rationale
Comprehensive testing prevents regressions and validates edge cases.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/ChromaTests/Main.lean` (lines 24-25)
