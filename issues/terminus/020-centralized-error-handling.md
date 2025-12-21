# Centralized Error Handling

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
FFI functions return IO errors but error messages are hardcoded strings.

## Rationale
Define a `TerminalError` inductive type with structured error information.

Better error handling, testability, and user feedback.

## Affected Files
- New file: `Terminus/Core/Error.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Backend/Raw.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/ffi/terminus.c`
