# Add Monadic Interface for Cache Operations

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description

Cache operations return raw values, requiring manual threading of state.

## Proposed Change

Add a `CacheM` monad that encapsulates cache state and IO:

```lean
abbrev CacheM (K : Type) [BEq K] [Hashable K] := StateT (CacheIndex K) IO

def runCacheM [BEq K] [Hashable K] (index : CacheIndex K)
    (action : CacheM K α) : IO (α × CacheIndex K) :=
  action.run index
```

## Benefits

Cleaner composition of cache operations, easier error handling.

## Affected Files

- New file `Cellar/Monad.lean`
