# Cache Statistics and Metrics

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** Cache Type with Integrated State Management (to track operations)

## Description

Track cache hit/miss counts and other usage statistics.

## Rationale

Useful for debugging, tuning cache sizes, and understanding cache effectiveness.

## Proposed API

```lean
structure CacheStats where
  hits : Nat
  misses : Nat
  evictions : Nat
  bytesWritten : Nat
  bytesRead : Nat
  deriving Repr, Inhabited

def CacheStats.hitRate (stats : CacheStats) : Float :=
  if stats.hits + stats.misses == 0 then 0.0
  else stats.hits.toFloat / (stats.hits + stats.misses).toFloat
```

## Affected Files

- New file `Cellar/Stats.lean`
- Updates to `Cellar/Config.lean`
