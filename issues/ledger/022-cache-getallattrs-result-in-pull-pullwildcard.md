# Cache getAllAttrs Result in Pull.pullWildcard

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`getAllAttrs` in `Ledger/Pull/Executor.lean` iterates through entity datoms and deduplicates attributes on every wildcard pull.

## Rationale
Consider caching attribute lists per entity, or using a set for deduplication.

Benefits:
- Faster wildcard pulls
- Reduced memory allocations
- Better performance for repeated pulls

## Affected Files
- `Ledger/Pull/Executor.lean` (lines 66-77)
