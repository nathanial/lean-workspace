# Proper Nested Message Decoding in Codegen

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The current code generation for decoding named types and nested messages uses `skipField` instead of actually decoding the embedded message.

## Rationale
This is a significant functionality gap. Lines 57-58 and 72-73 in `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean` skip nested messages rather than decoding them properly.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Decode.lean` (implement proper embedded message decoding)
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Encode.lean` (verify embedded encoding is correct)
