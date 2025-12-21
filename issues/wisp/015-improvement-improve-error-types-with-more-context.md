# Improve Error Types with More Context

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`WispError` variants like `curlError` and `ioError` only contain a message string.

## Rationale
Add structured error data:
- Include curl error code as a field (not just in message)
- Add request URL to connection errors
- Include response body in HTTP errors when available

Benefits:
- Enables programmatic error handling
- Better debugging experience
- Pattern matching on specific errors

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Error.lean`
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean`
