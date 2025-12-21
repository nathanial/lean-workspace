# Extract Duplicate Packed Encode/Decode Patterns

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Repeated.lean` has repetitive encode/decode functions that differ only in the emit/read call.

## Rationale
Create generic `encodePackedWith` and `decodePackedWith` functions that take the emit/read operation as a parameter.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Repeated.lean`, lines 18-148
