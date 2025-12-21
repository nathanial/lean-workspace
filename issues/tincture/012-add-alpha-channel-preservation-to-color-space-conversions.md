# Add Alpha Channel Preservation to Color Space Conversions

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Alpha channel handling is inconsistent across color space types. For example, `HSL`, `HSV`, `HWB`, `Lab`, `LCH`, `OkLab`, `OkLCH`, `XYZ`, and `CMYK` structures do not store alpha. The alpha is passed separately to `toColor` but lost during `fromColor`.

## Rationale
Either:
1. Add an `alpha` field to each color space structure, or
2. Create wrapper types that consistently carry alpha alongside the color space data, or
3. Document the pattern clearly and ensure all `toColor` methods accept alpha

Consistent alpha handling, prevents subtle bugs when converting between color spaces.

## Affected Files
- All files in `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/`
