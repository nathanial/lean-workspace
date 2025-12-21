# HTTP/2 and HTTP/3 Configuration

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** libcurl built with HTTP/2 (nghttp2) and/or HTTP/3 (ngtcp2/quiche)

## Description
Expose HTTP/2 and HTTP/3 settings for modern protocol support.

## Rationale
HTTP/2 and HTTP/3 offer performance benefits. While libcurl may default to these, explicit configuration would allow:
- Forcing specific HTTP versions
- Enabling ALPN negotiation
- HTTP/3 (QUIC) support for low-latency connections

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Request.lean` - Already has HttpVersion type but not fully used
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` - Apply HTTP version settings
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean` - Add CURLOPT_HTTP_VERSION binding
