# Remove Duplicate Helper Functions in Tests

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The test files each define their own `approxEq` and `colorApproxEq` helper functions:
- `TinctureTests/ColorTests.lean` (lines 14-22)
- `TinctureTests/SpaceTests.lean` (lines 14-21)
- `TinctureTests/BlendTests.lean` (lines 14-21)
- `TinctureTests/ContrastTests.lean` (lines 14-15)
- `TinctureTests/HarmonyTests.lean` (lines 14-15)
- `TinctureTests/ParseFormatTests.lean` (lines 14-21)
- `TinctureTests/PropertyTests.lean` (lines 63-69)

## Rationale
Extract shared test utilities into a common file (e.g., `TinctureTests/TestUtils.lean`) and import from all test files.

## Affected Files
- All test files in `/Users/Shared/Projects/lean-workspace/tincture/TinctureTests/`
