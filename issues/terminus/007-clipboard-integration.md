# Clipboard Integration

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add clipboard read/write support using OSC 52 escape sequences or platform-specific APIs.

## Rationale
Copy/paste functionality is essential for text input widgets. The TextArea and TextInput widgets would greatly benefit from clipboard integration.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Backend/Ansi.lean` (OSC 52 sequences)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/TextInput.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/TextArea.lean`
