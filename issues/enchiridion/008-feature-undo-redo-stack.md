# Undo/Redo Stack

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** May require terminus enhancements

## Description
Implement undo/redo functionality for text editing and structural changes.

## Rationale
Essential for any text editor. Currently there is no way to undo accidental deletions or changes.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/State/AppState.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/UI/Update.lean`
- Potentially requires changes to terminus TextArea
