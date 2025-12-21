# Proxy Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None (already using CURLOPT_PROXY constant in FFI)

## Description
Add HTTP/HTTPS/SOCKS proxy configuration.

## Rationale
Many enterprise environments require proxy usage. libcurl already supports proxies, but the Lean API does not expose this functionality.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Request.lean` - Add proxy configuration to Request
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` - Apply proxy settings
