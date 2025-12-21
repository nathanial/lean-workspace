# Consider BEq Instance for CacheEntry

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

The current `BEq` instance for `CacheEntry` only compares `filePath`, ignoring other fields. This may lead to unexpected behavior.

## Affected Files

- `Cellar/Config.lean`, lines 29-30

## Action Required

Either:
1. Remove the instance and let users compare entries explicitly
2. Document the behavior clearly
3. Change to compare all relevant fields

```lean
-- Current (potentially confusing):
instance [BEq K] : BEq (CacheEntry K) where
  beq a b := a.filePath == b.filePath

-- Alternative (more explicit):
instance [BEq K] : BEq (CacheEntry K) where
  beq a b := a.key == b.key && a.filePath == b.filePath
```
