---
id: 6
title: Implement edit issue form in TUI
status: closed
priority: high
created: 2026-01-06T13:21:09
updated: 2026-01-06T14:04:47
labels: [feature]
assignee: 
blocks: []
blocked_by: [5]
---

# Implement edit issue form in TUI

## Description
The ViewMode.edit exists but form rendering and input handling are TODO. Need to implement:
- Pre-populate form with existing issue data
- Allow editing title, description, priority, labels, assignee
- Save/cancel handling
- Keybinding to enter edit mode from detail view (e)

## Progress
- [2026-01-06T14:04:31] Added assignee field to edit form: FormField.assignee, FormState.assignee, fromIssue/getAssignee methods, drawForm rendering, and PendingAction handlers
- [2026-01-06T14:04:46] Closed: Implemented edit issue form in TUI. Added assignee field support (FormField.assignee, FormState.assignee with fromIssue/getAssignee). Form now supports editing: title, description, priority, labels, and assignee. Keybinding 'e' from detail view enters edit mode. Ctrl+S saves, Esc cancels.
