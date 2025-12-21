# Shadow and Blur Effects

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add render commands for drop shadows and blur effects.

## Rationale
Shadows are essential for modern UI design to convey depth and hierarchy. The render command abstraction makes this straightforward to add.

## Affected Files
- `Arbor/Core/Types.lean` - add `Shadow` type
- `Arbor/Render/Command.lean` - add shadow/blur commands
- `Arbor/Widget/Core.lean` - add `BoxStyle.shadow` field

## Proposed API
```lean
structure Shadow where
  offsetX : Float
  offsetY : Float
  blur : Float
  spread : Float
  color : Color
  inset : Bool := false

inductive RenderCommand where
  | ... -- existing commands
  | withShadow (shadow : Shadow) (cmds : Array RenderCommand)
  | blur (rect : Rect) (radius : Float)
```
