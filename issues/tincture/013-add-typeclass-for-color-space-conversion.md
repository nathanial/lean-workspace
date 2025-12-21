# Add Typeclass for Color Space Conversion

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Each color space has its own `fromColor` and `toColor` functions, but there is no common interface (typeclass).

## Rationale
Create a `ColorSpace` typeclass with `fromColor` and `toColor` methods. This would enable generic programming over color spaces.

Enables generic algorithms, cleaner API, better composability.

## Affected Files
- All files in `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Space/`
- `/Users/Shared/Projects/lean-workspace/tincture/Tincture/Convert.lean`
