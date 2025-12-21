# Consolidate Point/Rect Type Conversions

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
There are repeated conversions between `Arbor.Rect` and `Trellis.LayoutRect`:
```lean
-- In Collect.lean
let r : Rect := ⟨⟨rect.x, rect.y⟩, ⟨rect.width, rect.height⟩⟩
-- In HitTest.lean
layout.borderRect.contains adjX adjY
```

Proposed change: Add explicit coercion instances or helper functions to reduce boilerplate.

## Rationale
Cleaner code, reduced duplication.

## Affected Files
- `Arbor/Core/Types.lean` - add `Coe` instances
- All files that convert between types
