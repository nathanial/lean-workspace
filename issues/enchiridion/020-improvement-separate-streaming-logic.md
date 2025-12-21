# Separate Streaming Logic

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
AI streaming is handled inline in `runLoop` which makes the function very long and complex.

## Rationale
Extract streaming management into a dedicated module or state machine.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/UI/App.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/AI/Streaming.lean`
