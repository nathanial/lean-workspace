# Add `@[inline]` Annotations for Performance-Critical Functions

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Many small helper functions like `AxisInfo.mainSize`, `EdgeInsets.horizontal`, etc. are not annotated for inlining.

Proposed change: Add `@[inline]` or `@[always_inline]` to frequently-called small functions.

## Rationale
Better runtime performance by avoiding function call overhead.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Axis.lean`
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Types.lean`
