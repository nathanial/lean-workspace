---
id: 166
title: Separate CLI and TUI mode detection
status: open
priority: medium
created: 2026-01-07T00:11:06
updated: 2026-01-07T00:11:06
labels: [refactor]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Separate CLI and TUI mode detection

## Description
Mode detection in Main.lean has manual help/version checks before Parlance parsing. Let Parlance handle all argument parsing for cleaner entry point.

