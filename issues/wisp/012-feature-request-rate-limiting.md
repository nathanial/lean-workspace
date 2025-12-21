# Request Rate Limiting

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add client-side rate limiting to avoid overwhelming servers.

## Rationale
Prevents 429 responses and ensures polite crawling/API usage.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` - Add rate limiter
