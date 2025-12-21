# Add Test Coverage for Distance Module

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
No dedicated unit tests exist for the color distance module (deltaE76, deltaE94, deltaE2000). Only property tests in `PropertyTests.lean` cover some aspects.

## Rationale
Create `TinctureTests/DistanceTests.lean` with tests for:
- Known deltaE values from the CIE publications
- Edge cases (same color, black/white, complementary colors)
- Symmetry and non-negativity

## Affected Files
- No `DistanceTests.lean` file exists
