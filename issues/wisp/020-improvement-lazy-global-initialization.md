# Lazy Global Initialization

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`globalInit` must be called explicitly before using the library. While `easyInit` calls it automatically, this is undocumented behavior.

## Rationale
Document the automatic initialization clearly and consider using `IO.initializing` pattern for truly lazy init.

Benefits:
- Better developer experience
- Less boilerplate in examples

## Affected Files
- `/Users/Shared/Projects/lean-workspace/wisp/README.md`
- `/Users/Shared/Projects/lean-workspace/wisp/Wisp/FFI/Easy.lean`
