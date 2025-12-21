# TTL (Time-to-Live) Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description

Add optional TTL-based expiration in addition to LRU eviction.

## Rationale

Some cache use cases require entries to expire after a fixed time period regardless of access patterns. This is common for HTTP caches and API response caching.

## Proposed Changes

- Add optional `ttlMs : Option Nat` field to `CacheConfig`
- Add `expiresAt : Option Nat` field to `CacheEntry`
- Implement `selectExpiredEntries` function
- Modify `selectEvictions` to consider TTL alongside LRU

## Affected Files

- `Cellar/Config.lean`
- `Cellar/LRU.lean`
