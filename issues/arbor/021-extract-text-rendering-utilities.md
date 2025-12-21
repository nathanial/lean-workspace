# Extract Text Rendering Utilities

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
`Arbor/Text/Renderer.lean` is 670 lines with multiple responsibilities: rendering, debugging, hierarchy display, and widget info collection.

Action required:
1. Extract `WidgetInfo` and collection logic to `Arbor/Debug/WidgetInfo.lean`
2. Keep core rendering in `Renderer.lean`
3. Move hierarchy/structure modes to `Arbor/Debug/Modes.lean`

## Rationale
Better separation of concerns, more maintainable code.

## Affected Files
- `Arbor/Text/Renderer.lean`
