# Compression Support

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add support for gRPC message compression (gzip, deflate).

## Rationale
Compression reduces network bandwidth for large messages, which is especially valuable for streaming RPCs with high message volumes.

## Affected Files
- `Legate/Metadata.lean` - add compression options to `CallOptions`
- `ffi/src/legate_ffi.cpp` - configure compression on context
