# CSS Grid `subgrid` Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement `subgrid` to allow nested grids to participate in their parent's track sizing.

## Rationale
Subgrid enables consistent alignment across nested grid structures.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Grid.lean` (new `Subgrid` track type)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (subgrid resolution logic)
