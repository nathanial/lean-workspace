# Key-to-Path Mapping Typeclass

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description

Add a `KeyPath` typeclass that allows users to define how cache keys map to file paths, centralizing path logic.

## Rationale

Currently, users must manually compute file paths for cache entries (as seen in afferent's `TileDiskCache`). A typeclass would standardize this pattern and reduce duplication.

## Proposed API

```lean
class KeyPath (K : Type) where
  toPath : CacheConfig -> K -> String
  fromPath : String -> Option K  -- For cache reconstruction

instance : KeyPath String where
  toPath config key := s!"{config.cacheDir}/{key}"
  fromPath path := some (System.FilePath.fileName path)
```

## Affected Files

- New file `Cellar/KeyPath.lean`
- Updates to `Cellar/Config.lean`
