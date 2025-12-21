# Item Count Limit

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description

Add option to limit cache by number of entries in addition to byte size.

## Rationale

Some use cases care more about the number of cached items than their total size.

## Proposed Changes

- Add `maxEntries : Option Nat` to `CacheConfig`
- Update `selectEvictions` to check both size and count limits

## Affected Files

- `Cellar/Config.lean`
- `Cellar/LRU.lean`
