# Oneof Field Code Generation

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Improve oneof field support with proper encoding/decoding in generated ProtoMessage instances.

## Rationale
Oneof inductive types are generated but the encoding/decoding logic for oneof fields is not included in the generated ProtoMessage instances.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Encode.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean`
