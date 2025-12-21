# ByteBuilder Size Tracking

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Track size during building instead of computing at the end.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/ByteArray/Builder.lean` (lines 42-43) must build the entire ByteArray to compute size. Add a size field to ByteBuilder that is incremented during building operations.

Benefits: O(1) size queries instead of O(n), useful for length-prefixed encoding

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/ByteArray/Builder.lean`
