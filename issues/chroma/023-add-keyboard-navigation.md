# Add Keyboard Navigation

**Priority:** Low
**Section:** Architectural Improvements
**Estimated Effort:** Medium
**Dependencies:** Afferent keyboard event support (already exists)

## Description
Only mouse interaction is supported.

Proposed change:
- Arrow keys to adjust hue/saturation/value
- Tab to move between components
- Enter to confirm, Escape to cancel
- Number keys for quick hue jumps (1-9 for 10%-90% around the wheel)

## Rationale
Accessibility, power-user efficiency.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean`
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/Main.lean`
