# Packed Repeated Field Decoding for All Types

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add missing packed decoding support for sint32, sint64, int64, uint32, and sfixed types.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Repeated.lean` has packed encoding functions for various types but the decode generation in `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean` only handles unpacked repeated fields. The decode field generation should detect repeated scalar fields and generate code that handles both packed and unpacked formats.

Benefits: Correct proto3 semantics (proto3 defaults to packed encoding for repeated scalars)

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean`
