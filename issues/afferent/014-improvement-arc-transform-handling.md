# Arc Transform Handling

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
In CanvasState.transformPath, arc commands transform the center but not the radius or angles (line 132-133 comment notes this).

## Rationale
Properly handle arc transforms including non-uniform scaling (may require converting arcs to beziers).

Benefits: Correct arc rendering under arbitrary transforms.

## Affected Files
- `Afferent/Canvas/State.lean` (transformPath function, lines 131-133)
