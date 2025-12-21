# Add Request/Response Debug Logging

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Verbose mode enables curl's debug output to stderr, but there's no structured logging.

## Rationale
Add optional structured logging that can be directed to a custom logger:
- Request method, URL, headers
- Response status, timing, headers
- Error details

Benefits:
- Better debugging support
- Integration with application logging

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean`
