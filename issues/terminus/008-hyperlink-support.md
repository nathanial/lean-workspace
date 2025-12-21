# Hyperlink Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add support for terminal hyperlinks using OSC 8 escape sequences, allowing clickable links in terminal output.

## Rationale
Modern terminals support hyperlinks (iTerm2, Windows Terminal, GNOME Terminal). This would enhance the utility of text widgets.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Backend/Ansi.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Cell.lean` (hyperlink attribute)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Core/Style.lean`
