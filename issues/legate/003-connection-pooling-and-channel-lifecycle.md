# Connection Pooling and Channel Lifecycle

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add connection pooling support and explicit channel lifecycle management APIs.

## Rationale
Listed in README as a TODO. For long-running applications, proper connection pooling prevents resource exhaustion and improves connection reuse. Currently channels are created but there is no pooling or explicit cleanup API exposed.

## Affected Files
- `Legate/Channel.lean` - add pool management
- New module: `Legate/Pool.lean`
- `ffi/src/legate_ffi.cpp` - add channel shutdown FFI
