# Client Interceptors

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Add client-side interceptor support for cross-cutting concerns like authentication, logging, metrics, and tracing.

## Rationale
Interceptors are the standard gRPC pattern for adding middleware functionality. This would enable auth token injection, request logging, and distributed tracing without modifying each call site.

## Affected Files
- New module: `Legate/Interceptor.lean`
- `Legate/Channel.lean` - add interceptor chain
- `Legate/Call.lean` - hook interceptors into call flow
- `Legate/Stream.lean` - hook interceptors into streaming calls
