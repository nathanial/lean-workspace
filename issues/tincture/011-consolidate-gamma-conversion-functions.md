# Consolidate Gamma Conversion Functions

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The gamma conversion functions (`gammaToLinear`, `linearToGamma`) are duplicated across multiple files:
- `Tincture/Space/RGB.lean` (lines 20-31)
- `Tincture/Space/XYZ.lean` (lines 25-37, marked `private`)
- `Tincture/Space/OkLab.lean` (lines 56-68, marked `private`)
- `Tincture/Blindness.lean` (lines 48-55, marked `private`)

## Rationale
Move these functions to a shared utility module (e.g., `Tincture/Util.lean` or export from `Tincture/Space/RGB.lean`) and have all files use the shared implementation.

DRY principle, easier maintenance, single source of truth for sRGB gamma curve.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/RGB.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/XYZ.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/OkLab.lean`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Blindness.lean`
