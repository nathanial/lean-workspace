---
id: 3
title: REPL support
status: closed
priority: high
created: 2026-01-06T14:47:03
updated: 2026-01-09T01:21:47
labels: []
assignee: 
project: parlance
blocks: [9]
blocked_by: []
---

# REPL support

## Description
Add support for building REPL-style interactive applications with readline, history, and tab completion. Gap between batch CLIs and full TUIs. Key features: line editing, history with ctrl+r search, tab completion, custom prompts. New files: Repl/Readline.lean, Repl/History.lean, Repl/Completion.lean, Repl/Loop.lean, ffi/readline.c

## Progress
- [2026-01-09T01:18:41] Implemented REPL history and tab completion features: Created History.lean (navigation, search, persistence), Completion.lean (provider interface, path/static/command completers), updated Core.lean with integration. All 126 tests pass.
- [2026-01-09T01:21:47] Closed: Released in v0.0.6 - Added REPL history (up/down navigation, Ctrl+R search, file persistence) and tab completion (static, path, command completers)
