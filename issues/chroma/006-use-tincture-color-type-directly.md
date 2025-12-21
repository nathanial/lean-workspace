# Use Tincture Color Type Directly

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Creating colors via `Color.hsv hue 1.0 1.0` in rendering code.

Proposed change:
- Store selected color as `Tincture.Color` in model
- Leverage Tincture's harmony, format, and conversion functions
- Use Tincture's HSV type for intermediate calculations

## Rationale
Full access to Tincture's color manipulation, consistent color handling.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean`
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/Main.lean`
