# Add ServerContext.peer Support

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`ServerContext.peer` field exists but is always empty string; the FFI does not populate it.

## Rationale
Extract peer address from `grpc::ServerContext::peer()` and pass to Lean handler.

Enables logging of client addresses, IP-based access control.

## Affected Files
- `ffi/src/legate_ffi.cpp` - extract peer in `handle_server_call`
- `Legate/Server.lean` - document the field
