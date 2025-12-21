# Sixel Graphics Support

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add Sixel graphics protocol support for displaying images in compatible terminals.

## Rationale
While iTerm2 protocol is supported via Image widget, Sixel has broader terminal support (xterm, mlterm, foot).

## Affected Files
- New file: `Terminus/Widgets/Sixel.lean` or extend Image widget
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Base64.lean` (encoding utilities)
