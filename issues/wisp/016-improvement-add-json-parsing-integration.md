# Add JSON Parsing Integration

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** Lean.Json or external JSON library

## Description
Response body is returned as raw `ByteArray` or `String`. JSON parsing must be done externally.

## Rationale
Add optional JSON parsing helpers:
- `Response.bodyJson? : IO (Option Lean.Json)`
- Consider integration with a Lean JSON library

Benefits:
- Convenient JSON response handling
- Type-safe JSON access

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Response.lean`
