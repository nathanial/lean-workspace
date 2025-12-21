# Animation System

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Add support for animated values and transitions between widget states.

## Rationale
Modern UI frameworks require animation support for polished user experiences. Arbor's render-command architecture is well-suited for this since animations would simply produce interpolated render commands over time.

## Affected Files
- `Arbor/Core/Animation.lean` (new file)
- `Arbor/Widget/Core.lean` - add animated widget variants
- `Arbor/Render/Command.lean` - animation-related commands

## Proposed API
```lean
structure AnimatedValue (α : Type) where
  current : α
  target : α
  duration : Float
  elapsed : Float
  easing : EasingFunction

inductive RenderCommand where
  | ... -- existing commands
  | animate (id : WidgetId) (property : AnimatableProperty) (value : AnimatedValue Float)
```
