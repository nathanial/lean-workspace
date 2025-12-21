# ProtoEnum Code Generation

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Generate ProtoEnum instances for parsed enum definitions to enable enum encode/decode.

## Rationale
Enum inductive types are generated in `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean` but ProtoEnum instances (toInt32/fromInt32) are not generated.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean` (add enum instance generation)
