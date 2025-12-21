# Add Synchronous Execution Option

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The `executeSync` function exists but is not prominently documented, and all convenience methods (`get`, `postJson`, etc.) return `Task`.

## Rationale
Add synchronous versions of convenience methods (`getSync`, `postJsonSync`, etc.) for simpler use cases where async is not needed.

Benefits:
- Simpler API for simple use cases
- Reduces boilerplate for scripts and CLI tools
- Better developer experience for beginners

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/HTTP/Client.lean`
