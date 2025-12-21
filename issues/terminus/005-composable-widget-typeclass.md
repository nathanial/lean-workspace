# Composable Widget Typeclass

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Introduce a Widget typeclass with methods for measuring preferred size, handling input events, and rendering. This would enable more sophisticated layout algorithms and event routing.

## Rationale
The current `Widget` class only has a `render` method. A richer interface would enable:
- Automatic size calculation for layouts
- Event bubbling and focus management
- Widget introspection

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/Widget.lean`
- All widget files would need to implement new methods
