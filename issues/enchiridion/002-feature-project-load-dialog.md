# Project Load Dialog

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add the ability to load existing projects from disk, not just save.

## Rationale
Currently the application only supports saving projects and always starts with a sample project. Users need to be able to open their previously saved work.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/UI/App.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/UI/Update.lean`
- `/Users/Shared/Projects/lean-workspace/enchiridion/Enchiridion/State/Focus.lean` (AppMode already has `.loading`)
