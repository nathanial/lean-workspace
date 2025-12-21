# Async Event Polling

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement non-blocking async I/O for event polling using Lean's Task system, allowing applications to perform background work while waiting for input.

## Rationale
The current synchronous polling model blocks the main thread. Async support would enable more sophisticated applications with background tasks.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/ffi/terminus.c` (select/poll-based reading)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Input/Events.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Backend/TerminalEffect.lean`
