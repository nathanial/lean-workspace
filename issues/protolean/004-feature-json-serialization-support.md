# JSON Serialization Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** JSON parsing library

## Description
Add JSON encoding and decoding for protobuf messages following the canonical JSON mapping.

## Rationale
JSON is the standard format for REST APIs and debugging. The proto3 spec defines a canonical JSON mapping that should be supported.

## Affected Files
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/JSON/Encoder.lean`
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/JSON/Decoder.lean`
- Create `/Users/Shared/Projects/lean-workspace/protolean/Protolean/JSON/Codec.lean`
