# Cookie Jar Support

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add automatic cookie management with persistent cookie storage across requests.

## Rationale
Currently cookies must be manually set via headers. A proper cookie jar would:
- Automatically persist cookies from Set-Cookie headers
- Send appropriate cookies based on domain/path
- Support cookie persistence to disk for session management
- Enable stateful HTTP interactions (login sessions, CSRF tokens)

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Request.lean` - Add cookieJar field to Request
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` - Integrate cookie jar handling
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean` - Expose CURLOPT_COOKIEFILE and CURLOPT_COOKIEJAR
