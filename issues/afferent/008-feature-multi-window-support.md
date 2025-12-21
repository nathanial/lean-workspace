# Multi-Window Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** Significant FFI and native code changes

## Description
Enable creating and managing multiple windows from a single application.

## Rationale
Some applications require multiple windows (toolbars, palettes, preview windows).

## Affected Files
- `Afferent/FFI/Window.lean`
- `Afferent/Canvas/Context.lean`
- `native/src/metal/window.m`
