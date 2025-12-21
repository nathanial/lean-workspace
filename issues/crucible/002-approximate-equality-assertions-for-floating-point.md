# Approximate Equality Assertions for Floating-Point

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description

Add built-in assertions for approximate float/number equality with configurable epsilon tolerance.

## Rationale

Multiple projects define their own `approxEq` helpers:
- `/Users/Shared/Projects/lean-workspace/tincture/TinctureTests/ColorTests.lean` lines 14-22
- `/Users/Shared/Projects/lean-workspace/tincture/TinctureTests/HarmonyTests.lean` line 14
- `/Users/Shared/Projects/lean-workspace/tincture/TinctureTests/ContrastTests.lean` line 14
- `/Users/Shared/Projects/lean-workspace/afferent/Afferent/Tests/Framework.lean` lines 12-19

These are all slightly different implementations of the same concept, indicating a missing core assertion.

## Affected Files

- `Crucible/Core.lean` - Add `shouldBeNear`, `shouldBeApprox` assertions
