# Consolidate Repr Instance for ByteArray

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
There are multiple Repr instances defined for ByteArray in different files.

## Rationale
Keep one canonical Repr instance and remove duplicates.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/ByteArray/Basic.lean`, lines 6-9
- `/Users/Shared/Projects/lean-workspace/protolean/Tests/Scalar.lean`, lines 13-14
