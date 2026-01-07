---
id: 167
title: Implement type-safe command dispatch
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

# Implement type-safe command dispatch

## Description
Command dispatch uses string matching on commandPath in Handlers.lean. Use a proper sum type for commands and pattern match for compiler-checked exhaustiveness.

