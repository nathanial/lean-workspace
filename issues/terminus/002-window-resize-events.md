# Window Resize Events

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Detect and handle terminal window resize events (SIGWINCH) so applications can dynamically adapt to size changes.

## Rationale
Currently, applications must poll for size changes. Native resize event support would make applications more responsive and efficient.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/ffi/terminus.c` (SIGWINCH handler)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Input/Events.lean` (ResizeEvent type)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Backend/TerminalEffect.lean`
