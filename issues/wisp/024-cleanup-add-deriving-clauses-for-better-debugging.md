# Add Deriving Clauses for Better Debugging

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Several types lack `Repr` derivations making debugging harder.

## Rationale
Add `deriving Repr` where missing, or implement `ToString` instances.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Request.lean` - `MultipartPart`, `Body`, `Auth`, `SslOptions`
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Response.lean` - `Response`
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Streaming.lean` - `StreamingResponse`
