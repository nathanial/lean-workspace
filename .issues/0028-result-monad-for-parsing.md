---
id: 28
title: Result monad for parsing
status: open
priority: low
created: 2026-01-06T14:48:37
updated: 2026-01-06T14:48:37
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Result monad for parsing

## Description
Provide monad for handling parse results with automatic help/version printing. User currently must handle Except and check for help/version errors manually. Proposed: runCli that auto-prints and exits. New file: Run.lean

