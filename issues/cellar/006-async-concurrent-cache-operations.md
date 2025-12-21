# Async/Concurrent Cache Operations

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Cache Type with Integrated State Management

## Description

Add thread-safe cache operations using Lean's `Mutex` or `IO.Ref.atomically`.

## Rationale

Disk caches are commonly accessed from multiple tasks/threads (e.g., background prefetching, concurrent tile downloads). Thread-safety is essential for production use.

## Proposed Changes

- Wrap `CacheIndex` access with mutex for thread safety
- Consider using `IO.Ref.atomically` for atomic updates
- Add async-friendly batch operations

## Affected Files

- `Cellar/Cache.lean` (new file)
- Potentially new `Cellar/Concurrent.lean`
