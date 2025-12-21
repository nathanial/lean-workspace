# CSS Grid Named Lines and Areas

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement support for named grid lines and `grid-template-areas` for semantic grid definitions. Currently, `GridLine.named` exists but is not processed (returns 0 in `resolveGridLine`).

## Rationale
Named lines and areas make complex grid layouts more maintainable and readable.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Grid.lean` (lines 68-73, `GridLine`)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (lines 457-470, 486-505)
