# Refactor Update Function

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The `update` function in `UI/Update.lean` is a large chain of if-else statements that is difficult to maintain.

## Rationale
Consider using pattern matching more extensively, or a command pattern to decouple key handling from actions.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/UI/Update.lean`
