# Unknown Field Preservation

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement full unknown field preservation during decode/encode roundtrips.

## Rationale
The `UnknownField` and `UnknownFields` types exist in `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Message.lean` (lines 9-20) but are not integrated into the code generation or decode loop.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Message.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Encode.lean`
