# Connection Pooling Configuration

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Expose connection pool configuration for better performance tuning.

## Rationale
libcurl maintains connection pools internally. Exposing configuration would allow:
- Setting max connections per host
- Setting total max connections
- Configuring keep-alive behavior
- Better resource management in high-throughput scenarios

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` - Add pool configuration
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean` - Add CURLOPT_MAXCONNECTS bindings
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Multi.lean` - Add CURLMOPT_* settings
