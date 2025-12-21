# Window Manager Integration

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None (but depends on afferent FFI extensions)

## Description
Provide utilities for managing multiple windows, window state (minimized, maximized), and window-level events.

## Rationale
Complex applications may have multiple windows (preferences, dialogs, tool palettes). Canopy could provide a window management layer above afferent's single-window API.

## Affected Files
- `Canopy/Window/Manager.lean` (new)
- `Canopy/Window/State.lean` (new)
