# Standardize Naming Conventions

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some inconsistencies in naming:
- `finish` vs `end` (GridSpan uses `finish` to avoid keyword, but could use backticks)
- `mk'` constructors vs named constructors
- `fromSizes` vs `pixels` (different patterns for similar functionality)

## Rationale
Establish and document naming conventions, then apply consistently.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Grid.lean` (line 78, `finish`)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Result.lean` (line 21, `mk'`)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Grid.lean` (lines 53-63)
