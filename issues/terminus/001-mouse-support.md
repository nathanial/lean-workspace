# Mouse Support

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add mouse event handling for click, scroll, and drag operations. This would enable interactive widgets like buttons, clickable lists, and drag-to-resize panels.

## Rationale
Modern terminal UI libraries like ratatui and crossterm provide mouse support. This is essential for building rich interactive applications and would significantly enhance the user experience of terminus-based applications.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Input/Events.lean` (add MouseEvent type)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Input/Key.lean` (extend Event type)
- `/Users/Shared/Projects/lean-workspace/terminus/ffi/terminus.c` (enable mouse tracking)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Backend/Ansi.lean` (mouse escape sequences)
