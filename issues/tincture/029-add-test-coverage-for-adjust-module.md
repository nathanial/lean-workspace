# Add Test Coverage for Adjust Module

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
No dedicated unit tests exist for color adjustment operations (lighten, darken, saturate, etc.).

## Rationale
Create `TinctureTests/AdjustTests.lean` with tests for:
- Lighten/darken
- Saturate/desaturate
- Hue rotation
- Invert, grayscale, sepia
- Brightness/contrast adjustments
- OkLCH-based adjustments

## Affected Files
- No `AdjustTests.lean` file exists
