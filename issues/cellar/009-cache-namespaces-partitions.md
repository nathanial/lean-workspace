# Cache Namespaces/Partitions

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Cache Type with Integrated State Management

## Description

Support multiple independent cache namespaces within a single cache directory.

## Rationale

Allows grouping related entries and managing them independently (e.g., clear all tiles without affecting other cached data).

## Proposed API

```lean
def CacheConfig.withNamespace (config : CacheConfig) (ns : String) : CacheConfig

-- Clear all entries in a namespace
def Cache.clearNamespace (cache : Cache K) (ns : String) : IO Unit
```

## Affected Files

- `Cellar/Config.lean`
- Cache module
