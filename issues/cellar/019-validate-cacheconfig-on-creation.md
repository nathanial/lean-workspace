# Validate CacheConfig on Creation

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description

`CacheConfig` can be created with invalid values (e.g., empty `cacheDir`, zero `maxSizeBytes`).

## Affected Files

- `Cellar/Config.lean`, line 10-15

## Action Required

Add validation function or smart constructor:

```lean
def CacheConfig.create (cacheDir : String) (maxSizeBytes : Nat) : Except String CacheConfig :=
  if cacheDir.isEmpty then .error "cacheDir cannot be empty"
  else if maxSizeBytes == 0 then .error "maxSizeBytes must be positive"
  else .ok { cacheDir, maxSizeBytes }
```
