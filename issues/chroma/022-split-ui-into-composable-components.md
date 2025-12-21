# Split UI into Composable Components

**Priority:** Medium
**Section:** Architectural Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
`pickerUI` function builds entire UI in one place.

Proposed change:
- Create separate widget components:
  - `hueWheel : HueWheelConfig -> WidgetBuilder`
  - `colorPreview : Color -> WidgetBuilder`
  - `colorSliders : Color -> WidgetBuilder`
  - `harmonyDisplay : Color -> HarmonyType -> WidgetBuilder`
- Use Arbor's composable widget pattern

## Rationale
Reusable components, easier testing, cleaner code organization.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (split into multiple files)
