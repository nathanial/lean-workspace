# Auto-Save Functionality

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement the auto-save feature that is already configured but not implemented.

## Rationale
The `Config` structure already has `autoSaveEnabled` and `autoSaveIntervalMs` fields, but the application does not use them. Auto-save is critical for a writing application to prevent data loss.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/UI/App.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/State/AppState.lean`
