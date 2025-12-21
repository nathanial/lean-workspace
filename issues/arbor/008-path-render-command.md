# Path Render Command

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add support for arbitrary vector paths (bezier curves, arcs).

## Rationale
The current command set only supports rectangles and convex polygons. Vector paths would enable more complex shapes.

## Affected Files
- `Arbor/Core/Path.lean` (new file)
- `Arbor/Render/Command.lean` - add path commands

## Proposed API
```lean
inductive PathSegment where
  | moveTo (x y : Float)
  | lineTo (x y : Float)
  | quadTo (cx cy x y : Float)
  | cubicTo (c1x c1y c2x c2y x y : Float)
  | arcTo (rx ry rotation largeArc sweep x y : Float)
  | close

inductive RenderCommand where
  | fillPath (segments : Array PathSegment) (color : Color)
  | strokePath (segments : Array PathSegment) (color : Color) (lineWidth : Float)
```
