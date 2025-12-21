# Complete Well-Known Types Implementation

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement remaining Google well-known types: Any, FieldMask, Struct, Value, ListValue, and Type/SourceContext/Api.

## Rationale
The current implementation covers Empty, Timestamp, Duration, and Wrapper types, but many proto files use Any for dynamic typing and FieldMask for partial updates.

## Affected Files
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WellKnown/Any.lean`
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WellKnown/FieldMask.lean`
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WellKnown/Struct.lean`
- Update `/Users/Shared/Projects/lean-workspace/protolean/Protolean/WellKnown.lean` (update registry)
