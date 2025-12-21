# Cache Type with Integrated State Management

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add a high-level `Cache` type that wraps `CacheIndex` with `IO.Ref` for stateful operations, providing a simpler API for common use cases.

## Rationale

Currently, users must manually manage the `CacheIndex` state and thread it through all operations. A stateful `Cache` type would reduce boilerplate and make the library easier to use correctly.

## Proposed API

```lean
structure Cache (K : Type) [BEq K] [Hashable K] where
  indexRef : IO.Ref (CacheIndex K)

namespace Cache
  def create (config : CacheConfig) : IO (Cache K)
  def get (cache : Cache K) (key : K) : IO (Option ByteArray)
  def put (cache : Cache K) (key : K) (data : ByteArray) : IO Unit
  def delete (cache : Cache K) (key : K) : IO Unit
  def clear (cache : Cache K) : IO Unit
end Cache
```

## Affected Files

- New file `Cellar/Cache.lean`
