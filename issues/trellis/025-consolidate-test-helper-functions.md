# Consolidate Test Helper Functions

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
`floatNear` and `shouldBeNear` in tests duplicate functionality that could be in the test framework (Crucible).

## Rationale
Either move to Crucible as reusable assertions or keep but add to a shared test utilities module.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/TrellisTests/Main.lean` (lines 16-22)
