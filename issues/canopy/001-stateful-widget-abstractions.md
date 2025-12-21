# Stateful Widget Abstractions

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Create higher-level stateful widget types that wrap Arbor's declarative widgets with state management, lifecycle hooks, and automatic ID tracking.

## Rationale
Arbor provides low-level display-only widgets with manual ID management. Applications like chroma must manually track widget IDs and register handlers separately. Canopy should provide stateful widget abstractions that automatically wire up event handlers.

## Affected Files
- `Canopy/Widget/Stateful.lean` (new)
- `Canopy/Widget/Component.lean` (new)

## Proposed Design
```lean
-- Example API
structure Component (Model Msg : Type) where
  init : Model
  view : Model -> WidgetBuilder
  update : Msg -> Model -> Model
  subscriptions : Model -> Array Subscription

-- Auto-wiring of handlers
def button (label : String) (onClick : Msg) : ComponentBuilder Msg Widget
```
