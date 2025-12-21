# Batch Capacity Growth Strategy

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Batch pre-allocates with capacity hints but growth strategy is implicit via Lean Array behavior.

## Rationale
Add explicit capacity doubling or configurable growth for very large batches.

Benefits: Better memory allocation patterns for scenes with many shapes.

## Affected Files
- `Afferent/Render/Tessellation.lean` (Batch namespace)
