# Animation System

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Stateful Widget Abstractions

## Description
Add declarative animation primitives for smooth transitions between states, spring physics, and easing functions.

## Rationale
Modern UI frameworks provide animation capabilities. Arbor widgets are static. Canopy should provide an animation layer that interpolates between widget states over time.

## Affected Files
- `Canopy/Animation/Core.lean` (new)
- `Canopy/Animation/Easing.lean` (new)
- `Canopy/Animation/Spring.lean` (new)
- `Canopy/Animation/Transition.lean` (new)

## Proposed Design
```lean
inductive Animation (a : Type) where
  | instant : a -> Animation a
  | tween : a -> a -> Duration -> Easing -> Animation a
  | spring : a -> a -> SpringConfig -> Animation a
  | sequence : Array (Animation a) -> Animation a
  | parallel : Array (Animation a) -> Animation a
```
