# Error Handling Improvements

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Many operations silently fail or return empty results. For example, `Config.loadFromFile` catches all exceptions and returns `none`.

## Rationale
Use proper error types with descriptive messages. Consider a unified Result monad or Except-based error handling.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Core/Config.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/Storage/FileIO.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/AI/OpenRouter.lean`
