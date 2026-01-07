---
id: 34
title: Consistent Error Handling Pattern
status: closed
priority: high
created: 2026-01-06T15:15:10
updated: 2026-01-07T00:55:38
labels: []
assignee: 
project: ask
blocks: []
blocked_by: []
---

# Consistent Error Handling Pattern

## Description
Create consistent error handling monad or pattern for uniform logging, printing, and exit codes. Current state mixes printError calls with return codes inconsistently.

## Progress
- [2026-01-07T00:55:33] Implemented consistent error handling pattern:
- [2026-01-07T00:55:38] Closed: Implemented Ask.Error module with unified error handling. All error paths now consistently log (when logger available) and print with appropriate styling.
