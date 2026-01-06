---
id: 3
title: REPL support
status: open
priority: high
created: 2026-01-06T14:47:03
updated: 2026-01-06T14:50:38
labels: []
assignee: 
project: parlance
blocks: [9]
blocked_by: []
---

# REPL support

## Description
Add support for building REPL-style interactive applications with readline, history, and tab completion. Gap between batch CLIs and full TUIs. Key features: line editing, history with ctrl+r search, tab completion, custom prompts. New files: Repl/Readline.lean, Repl/History.lean, Repl/Completion.lean, Repl/Loop.lean, ffi/readline.c

