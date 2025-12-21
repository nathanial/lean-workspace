# Focus Management System

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement a focus system for keyboard navigation between widgets.

## Rationale
Currently there is no focus tracking. Keyboard events go to no specific widget by default. For accessibility and usability, widgets need focus state management with tab navigation.

## Affected Files
- `Arbor/App/Focus.lean` (new file)
- `Arbor/Event/Types.lean` - add focus-related events
- `Arbor/App/UI.lean` - integrate focus into event dispatch

## Proposed API
```lean
structure FocusState where
  focused : Option WidgetId
  tabOrder : Array WidgetId
  focusVisible : Bool -- for keyboard-triggered focus styling

def Widget.focusable : Widget -> Bool
def FocusManager.focusNext : FocusState -> Widget -> FocusState
def FocusManager.focusPrev : FocusState -> Widget -> FocusState
```
