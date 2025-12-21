# ProtoMergeable Implementation

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement proper message merging semantics.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Message.lean` (lines 88-95) has a `ProtoMergeable` class but the default instance just takes the later value. Implement recursive merging for embedded messages, concatenation for repeated fields.

Benefits: Correct proto semantics for duplicate fields

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Message.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean`
