# Implement Efficient Range Queries in Indexes

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
All index query functions (`datomsForEntity`, `datomsForAttr`, etc.) in EAVT.lean, AEVT.lean, AVET.lean, and VAET.lean use `Batteries.RBMap.toList` followed by `filterMap`. This is O(n) for every query regardless of result size.

## Rationale
Use RBMap's range query capabilities or implement a B-tree/skip list for efficient range scans:
- Use `RBMap.foldlM` with early termination
- Or implement lower/upper bound navigation
- Or switch to a data structure with native range query support

Benefits:
- O(log n + k) query time where k is result size
- Significant performance improvement for selective queries
- Required for production-scale workloads

## Affected Files
- `Ledger/Index/EAVT.lean` (lines 39-57)
- `Ledger/Index/AEVT.lean` (lines 35-50)
- `Ledger/Index/AVET.lean` (lines 36-60)
- `Ledger/Index/VAET.lean` (lines 41-65)
