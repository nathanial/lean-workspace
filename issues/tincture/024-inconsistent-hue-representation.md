# Inconsistent Hue Representation

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Hue is represented as `0.0 to 1.0` (normalized) in all color spaces, but some helper functions like `rotateHueDeg` accept degrees. The documentation could be clearer about this.

## Rationale
Add clear documentation about the hue convention. Consider adding more degree-based convenience functions if commonly needed.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/HSL.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/HSV.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Adjust.lean` (line 41)
