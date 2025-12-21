# Improve LRU Algorithm Efficiency

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** May require additional data structure from batteries or custom implementation

## Description

`selectEvictions` in `Cellar/LRU.lean` converts HashMap to list, sorts the entire list, then iterates.

```lean
let sorted := index.entries.toList.map Prod.snd
  |>.toArray.qsort (fun a b => a.lastAccessTime < b.lastAccessTime)
  |>.toList
```

## Proposed Change

Use a priority queue or maintain a separate sorted structure for LRU ordering. Consider:
- `BinaryHeap` for O(log n) insert/extract-min
- Doubly-linked list with HashMap for O(1) operations (classic LRU cache pattern)

## Benefits

Better asymptotic performance for large caches.

## Affected Files

- `Cellar/LRU.lean`
- Possibly new `Cellar/PriorityQueue.lean`
