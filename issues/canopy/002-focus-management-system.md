# Focus Management System

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Stateful Widget Abstractions

## Description
Implement keyboard focus traversal, focus rings, and focus state tracking across the widget tree.

## Rationale
Arbor's event system handles pointer events well but lacks focus management for keyboard navigation. Desktop applications require Tab/Shift-Tab focus cycling, focus indicators, and focus-aware keyboard event routing.

## Affected Files
- `Canopy/Focus/State.lean` (new)
- `Canopy/Focus/Traversal.lean` (new)
- `Canopy/Focus/Ring.lean` (new)

## Proposed API
```lean
structure FocusState where
  focusedId : Option WidgetId
  focusRing : Array WidgetId  -- Ordered focusable widgets
  tabIndex : HashMap WidgetId Int

def focusNext (state : FocusState) : FocusState
def focusPrev (state : FocusState) : FocusState
def handleFocusKey (key : Key) (state : FocusState) : FocusState
```
