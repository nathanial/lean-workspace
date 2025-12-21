# Keyboard Event API Enhancement

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add higher-level keyboard event handling with key names (not just key codes), text input support, and key repeat detection.

## Rationale
Current API returns raw key codes which require manual mapping. Text input for text fields is not directly supported.

## Affected Files
- `Afferent/FFI/Window.lean` (new FFI functions)
- `native/src/metal/window.m` (text input delegates)
