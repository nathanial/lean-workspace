# Per-RPC Credentials

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add support for per-RPC credentials (auth tokens) rather than channel-level credentials only.

## Rationale
Many auth patterns (OAuth, JWT) require injecting credentials per-call rather than per-channel, especially when tokens have short lifetimes.

## Affected Files
- `Legate/Metadata.lean` - add credentials option
- `ffi/src/legate_ffi.cpp` - set call credentials
