# Cursor Customization

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add ability to change the mouse cursor (pointer, text, crosshair, custom image).

## Rationale
Different cursor styles provide important UI feedback.

## Affected Files
- `Afferent/FFI/Window.lean` (new FFI function)
- `native/src/metal/window.m` (NSCursor handling)
