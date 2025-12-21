# Improve LayoutResult Lookup Performance

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`LayoutResult.get` uses `Array.find?` which is O(n) lookup (line 107-108).

Proposed change: Use a `HashMap NodeId ComputedLayout` or maintain sorted array for binary search.

## Rationale
O(1) or O(log n) lookups instead of O(n) for large layout trees.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Result.lean` (lines 98-141)
