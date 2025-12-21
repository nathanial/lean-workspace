# Add Test Suite

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description

The project has no tests (noted in CLAUDE.md: "Projects without a test target: canopy, cellar, crucible").

## Affected Files

- Project-wide

## Action Required

1. Add crucible as a dependency in `lakefile.lean`
2. Create `Cellar/Tests/` directory with test files:
   - `ConfigTests.lean` - Test CacheConfig, CacheEntry, CacheIndex
   - `LRUTests.lean` - Test eviction logic
   - `IOTests.lean` - Test file operations (with temp directories)
3. Add test target to lakefile
