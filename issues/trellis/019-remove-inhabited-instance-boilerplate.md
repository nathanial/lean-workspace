# Remove Inhabited Instance Boilerplate

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Multiple structures define default values both as an `Inhabited` instance and as explicit `default`/`empty`/`zero` functions.

Proposed change: Use `deriving Inhabited` with `@[default_instance]` where possible, or consolidate to a single source of truth.

## Rationale
Less redundant code, single source of truth for defaults.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Flex.lean` (lines 79, 109)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Grid.lean` (lines 51, 144)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Types.lean`
