# Unified Varint Encoding to Builder

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Emit varints directly to ByteBuilder instead of creating intermediate ByteArrays.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Encoder.lean` (lines 44-49) create intermediate ByteArrays via Varint.encodeUInt64/32. Add `ByteBuilder.varint` that writes directly without intermediate allocation.

Benefits: Reduced allocations, better performance

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/ByteArray/Builder.lean`
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Encoder.lean`
