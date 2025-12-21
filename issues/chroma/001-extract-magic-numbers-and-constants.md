# Extract Magic Numbers and Constants

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The codebase contains hardcoded magic numbers scattered throughout:
- `6.283185307179586` (2*pi) appears multiple times in `ColorPicker.lean`
- Screen scale multipliers like `24 * screenScale`, `32 * screenScale` are inline
- Font size calculations `28 * screenScale`, `16 * screenScale` are hardcoded
- Widget ID comment `-- Widget IDs (build order): 0: column root, 1: title text...`

Proposed change:
- Define `twoPi` or `tau` constant in a shared location
- Create a `Theme` or `Sizes` structure for UI constants
- Use semantic names like `titleFontSize`, `bodyFontSize`, `defaultPadding`

## Rationale
Improved maintainability, easier theming, self-documenting code.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (lines 54-55, 104, 128, 158, 163)
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/Main.lean` (lines 29-30, 39, 43, 204)
