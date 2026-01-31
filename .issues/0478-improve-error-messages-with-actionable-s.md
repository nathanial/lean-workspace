---
id: 478
title: Improve error messages with actionable suggestions
status: closed
priority: medium
created: 2026-01-29T05:56:45
updated: 2026-01-31T00:28:15
labels: [tech-debt]
assignee: 
project: image-gen
blocks: []
blocked_by: []
---

# Improve error messages with actionable suggestions

## Description
Technical debt: Improve error messages to include actionable suggestions for users.

## Progress
- [2026-01-31T00:18:48] Explored tracker codebase - found 40 distinct error messages across Handlers.lean, Main.lean, and Storage.lean. Only 1 error has actionable suggestion. Key improvement areas: validation errors, not-found errors, and operation failures.
- [2026-01-31T00:28:09] Implementation complete. Updated formatError to accept optional suggestion parameter. Added hints to all validation errors (Issue ID/Title/--by required), not-found errors, and unknown command. JSON output includes suggestion field. All 23 tests pass.
- [2026-01-31T00:28:15] Closed: Implemented actionable suggestions for all tracker error messages. Changes: (1) Extended formatError in Output.lean with optional suggestion parameter, (2) Updated all 32 applicable errors in Handlers.lean with hints, (3) Added errorSuggestion field to TUI State.lean with updated setError/clearMessages helpers, (4) Updated footerWidget in App.lean to display suggestions. Text output shows 'Hint:' on separate line, JSON includes 'suggestion' field.
