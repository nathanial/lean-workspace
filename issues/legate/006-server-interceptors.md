# Server Interceptors

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Add server-side interceptor support for authentication, authorization, logging, and metrics.

## Rationale
Server interceptors enable implementing auth checks, request logging, and metrics collection as reusable middleware rather than per-handler logic.

## Affected Files
- `Legate/Server.lean` - add interceptor registration
- `ffi/src/legate_ffi.cpp` - hook interceptors into call dispatch
