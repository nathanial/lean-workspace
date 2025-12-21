# Eliminate Partial Functions in Decoder

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Replace partial `decodeMessageLoop` and `decodeEmbeddedLoop` with total functions using fuel or termination proofs.

## Rationale
`/Users/Shared/Projects/lean-workspace/protolean/Protolean/Message.lean` (lines 36, 54) use `partial` for the decode loops. Use fuel parameter or prove termination based on input byte consumption.

Benefits: Improved safety guarantees, better compile-time verification

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Message.lean`
