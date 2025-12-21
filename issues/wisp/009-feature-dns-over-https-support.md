# DNS-over-HTTPS (DoH) Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add configuration for DNS-over-HTTPS resolvers.

## Rationale
DoH provides privacy and security for DNS lookups. libcurl supports DoH and this could be exposed.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Request.lean` - Add DoH configuration
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean` - Add CURLOPT_DOH_URL binding
