# Use Nat Subtraction Safely

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

In `Cellar/LRU.lean`, `removeEntries` uses natural number subtraction which could silently underflow if `removedSize > totalSizeBytes`.

## Affected Files

- `Cellar/LRU.lean`, line 46-53

## Action Required

Add guard or use saturating subtraction:

```lean
let newSize := if removedSize > index.totalSizeBytes then 0
               else index.totalSizeBytes - removedSize
```
