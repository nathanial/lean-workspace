# Cross-Platform Windows Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Add Windows Console API support as an alternative backend to the Unix termios-based implementation.

## Rationale
Currently terminus only works on Unix-like systems. Windows support would significantly expand the library's utility.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/ffi/terminus.c` (add Windows conditionals)
- New file: `ffi/terminus_win.c` (Windows-specific implementation)
- `/Users/Shared/Projects/lean-workspace/terminus/lakefile.lean` (conditional compilation)
