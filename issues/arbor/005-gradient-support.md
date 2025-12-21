# Gradient Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** Tincture gradient types

## Description
Add render commands for linear and radial gradients.

## Rationale
Tincture already provides gradient types. Arbor should support rendering gradients for backgrounds and fills.

## Affected Files
- `Arbor/Render/Command.lean` - add gradient commands
- `Arbor/Widget/Core.lean` - add `BoxStyle.backgroundGradient`

## Proposed API
```lean
inductive GradientType where
  | linear (angle : Float)
  | radial (centerX centerY : Float)

structure Gradient where
  type : GradientType
  stops : Array (Float × Color)

inductive RenderCommand where
  | ... -- existing commands
  | fillGradient (rect : Rect) (gradient : Gradient)
```
