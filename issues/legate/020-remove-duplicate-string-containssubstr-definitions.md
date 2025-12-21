# Remove Duplicate String.containsSubstr Definitions

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The helper function `String.containsSubstr` is defined identically in three files.

## Rationale
Define once in `Tests/Framework.lean` (already exists there) and remove duplicates from test files.

## Affected Files
- `Tests/ErrorTests.lean` (line 14)
- `Tests/MetadataTests.lean` (line 14)
- `Tests/StatusTests.lean` (line 14)
- `Tests/Framework.lean` (line 8)
