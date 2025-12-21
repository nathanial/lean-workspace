# Unused ctx Parameter in Code Generation

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `ctx` parameter is often unused in code generation functions.

## Rationale
Either remove unused parameters or document why they are kept for future use.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean`, line 75 (`_ctx`)
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean`, line 103 (`_ctx`)
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Service.lean`, lines 42, 50 (`_ := ctx`)
