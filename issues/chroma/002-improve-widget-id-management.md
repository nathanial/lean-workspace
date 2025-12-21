# Improve Widget ID Management

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Widget IDs are manually tracked via comments:
```lean
-- Widget IDs (build order):
-- 0: column root
-- 1: title text
-- 2: color picker
-- 3: subtitle text
UIBuilder.register 2 (pickerHandler config)
```

Proposed change:
- Use named widgets via Arbor's `namedCustom` and lookup by name
- Alternatively, capture widget ID from builder and use it directly
- Consider adding a `colorPickerWidget` function that returns its ID

## Rationale
Less fragile code, no need to manually track build order, fewer bugs when UI changes.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (lines 200-215)
