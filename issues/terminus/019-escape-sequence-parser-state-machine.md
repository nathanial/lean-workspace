# Escape Sequence Parser State Machine

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Escape sequence parsing in `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Input/Events.lean` uses nested pattern matching which is hard to extend.

## Rationale
Implement a proper state machine parser that can handle arbitrary escape sequences, including CSI parameters.

More robust input handling, easier to add new key sequences.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Input/Events.lean`
