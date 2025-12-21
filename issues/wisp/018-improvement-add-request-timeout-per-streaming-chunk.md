# Add Request Timeout per Streaming Chunk

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Streaming responses use the overall request timeout. If a server sends data slowly, chunks may arrive indefinitely.

## Rationale
Add a per-chunk timeout for streaming responses to detect stalled connections.

Benefits:
- Better handling of slow/stalled connections
- More predictable streaming behavior

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Streaming.lean`
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean`
