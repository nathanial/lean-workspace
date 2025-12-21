# Add BEq Instance for WispError

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
`WispError` in `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Error.lean` lacks `BEq` and `Hashable` instances.

## Rationale
Add `deriving BEq` to WispError or implement manual instance.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/Core/Error.lean:174-182`
