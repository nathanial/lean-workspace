# Add Documentation Comments to Public API

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
While there are some doc comments, many public functions lack comprehensive documentation. For example, the main `layout` function (line 955-956) has no doc comment explaining parameters and return value.

## Rationale
Add `/-!` section comments and `/--` doc comments to all public functions.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean`
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Node.lean`
