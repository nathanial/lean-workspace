# Extract Duplicate Request Setup Logic

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `execute` and `executeStreaming` functions in `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean` contain nearly identical code for setting up curl options (~200 lines duplicated, lines 314-448 and 458-603).

## Rationale
Extract the common request setup logic into a shared helper function like `setupEasyHandle : Client -> Request -> IO (Wisp.FFI.Easy × Wisp.FFI.Slist)`.

Benefits:
- Eliminates code duplication
- Makes maintenance easier
- Reduces risk of inconsistencies between execution modes
- Improves readability

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean`
