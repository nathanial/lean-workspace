# Eliminate Partial Functions

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Multiple functions are marked `partial` due to recursive widget tree traversal:
- `Widget.widgetCount` (Core.lean:206)
- `Widget.allIds` (Core.lean:210)
- `measureWidget` (Measure.lean:40)
- `intrinsicSize` (Measure.lean:179)
- `collectWidget` (Collect.lean:90)
- `collectDebugBorders` (Collect.lean:161)
- `hitTest` (HitTest.lean:41)
- `hitTestAll` (HitTest.lean:107)
- `pathToWidget` (HitTest.lean:162)
- `collectWidgetInfo` (Renderer.lean:402)

Proposed change: Use well-founded recursion with fuel parameter or widget depth bound to prove termination.

## Rationale
Total functions are safer and enable more Lean optimizations.

## Affected Files
All files listed above
