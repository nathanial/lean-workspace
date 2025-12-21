# Add Saturation/Value Picker

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None (Arbor custom widget support already exists)

## Description
Implement the inner triangle or square picker for selecting saturation and value at the current hue.

## Rationale
A hue wheel alone is not sufficient for a functional color picker. Users need to select saturation and value/lightness as well.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (new widget or extension)
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/Main.lean`
