# Proper arcTo Implementation

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The arcTo command in path tessellation is simplified to just draw lines to p1 and p2 (line 116).

## Rationale
Implement proper arcTo geometry that draws a line to p1 then an arc tangent to both lines with the given radius.

Benefits: Correct HTML5 Canvas API compatibility for rounded corners and path effects.

## Affected Files
- `Afferent/Render/Tessellation.lean` (pathToPolygonWithClosed, lines 113-118)
