# Separate Model from UI Configuration

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`PickerModel` only tracks hue and drag state, while `ColorPickerConfig` mixes rendering config with state:
```lean
structure PickerModel where
  hue : Float := 0.08
  dragging : Bool := false

structure ColorPickerConfig where
  selectedHue : Float := 0.08  -- Duplicated from model!
  selectedSaturation : Float := 1.0
  selectedValue : Float := 1.0
```

Proposed change:
- Expand `PickerModel` to include saturation, value, and other state
- Make `ColorPickerConfig` purely about rendering (sizes, colors, segments)
- Pass model values to config at render time instead of duplicating

## Rationale
Single source of truth for color state, cleaner separation of concerns.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (structures at lines 15-49)
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/Main.lean` (lines 36-46)
