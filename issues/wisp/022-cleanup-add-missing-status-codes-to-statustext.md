# Add Missing Status Codes to statusText

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `statusText` function in `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Response.lean` (lines 75-103) is missing several common HTTP status codes.

## Rationale
Add missing status codes:
- 206 Partial Content
- 301 Moved Permanently (missing descriptive handling)
- 405 Method Not Allowed
- 406 Not Acceptable
- 411 Length Required
- 413 Payload Too Large
- 415 Unsupported Media Type
- 422 Unprocessable Entity
- 451 Unavailable For Legal Reasons

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Response.lean:75-103`
