# Modularize Geometry Functions

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Geometry utilities (`circlePoints`, `ringSegmentPoints`, `orientedRectPoints`) are defined inline in `ColorPicker.lean`.

Proposed change:
- Move to `Chroma/Geometry.lean` module
- Consider contributing generic versions to Arbor if useful there
- Add documentation and unit tests for these functions

## Rationale
Better code organization, reusable geometry utilities, testable in isolation.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (lines 51-91)
