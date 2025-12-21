# Add Repr Instance for CacheIndex

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

`CacheIndex` has `Inhabited` but not `Repr`, making debugging harder.

## Affected Files

- `Cellar/Config.lean`, line 33-40

## Action Required

Add `Repr` instance:

```lean
instance [Repr K] [BEq K] [Hashable K] : Repr (CacheIndex K) where
  reprPrec idx _ :=
    s!"CacheIndex(entries: {idx.entries.size}, totalSize: {idx.totalSizeBytes}B)"
```
