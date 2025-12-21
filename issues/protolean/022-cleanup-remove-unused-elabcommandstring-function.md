# Remove Unused elabCommandString Function

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `elabCommandString` function in `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean` (lines 162-171) only logs generated code and has a TODO comment. The actual elaboration happens via `elaborateCodeString` in Import.lean.

## Rationale
Remove `elabCommandString`, `elaborateMessage`, and `elaborateEnum` functions as they are unused (Import.lean uses `elaborateCodeString` and `generateMessageString`/`generateEnumString` directly).

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean`, lines 162-176
