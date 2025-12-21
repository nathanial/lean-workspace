# Cache Persistence and Reconstruction

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Key-to-Path Mapping Typeclass (for `fromDirectory`)

## Description

Add functionality to persist the cache index to disk and reconstruct it on startup by scanning the cache directory.

## Rationale

Currently, the in-memory index is lost when the application exits. Users must rebuild the index by scanning the filesystem, but no helper functions exist for this.

## Proposed API

```lean
-- Scan directory and rebuild index
def CacheIndex.fromDirectory [KeyPath K] (config : CacheConfig) : IO (CacheIndex K)

-- Persist index to disk (optional, for faster startup)
def CacheIndex.save (index : CacheIndex K) (path : String) : IO Unit
def CacheIndex.load (path : String) : IO (Except String (CacheIndex K))
```

## Affected Files

- New file `Cellar/Persist.lean`
- Updates to `Cellar/IO.lean`
