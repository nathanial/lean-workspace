# Introduce Application State Management

**Priority:** Medium
**Section:** Architectural Improvements
**Estimated Effort:** Large
**Dependencies:** None

## Description
State is minimal (`PickerModel` with just hue and dragging).

Proposed change:
- Design a comprehensive `AppState` with:
  - Current color (HSV and RGB representations)
  - UI mode (picker, harmony, palette, etc.)
  - History for undo/redo
  - Saved palettes
- Consider using Collimator lenses for nested state updates

## Rationale
Foundation for complex features, undo/redo support, state persistence.

## Affected Files
- New file: `/Users/Shared/Projects/lean-workspace/chroma/Chroma/State.lean`
- All existing files
