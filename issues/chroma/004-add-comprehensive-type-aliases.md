# Add Comprehensive Type Aliases

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Raw `Float` used everywhere for different semantic meanings (angles, positions, sizes, hue values).

Proposed change:
- Define type aliases: `abbrev Hue := Float`, `abbrev Radians := Float`, `abbrev Degrees := Float`
- Consider using Lean's units-of-measure patterns for stronger type safety
- Use `Point` from Arbor consistently instead of separate x/y floats

## Rationale
Self-documenting code, potential for compile-time unit checking.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/chroma/Chroma/ColorPicker.lean` (throughout)
