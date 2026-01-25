---
id: 395
title: Add traceDynamic debugging utility
status: closed
priority: high
created: 2026-01-17T09:42:41
updated: 2026-01-25T02:42:31
labels: [debugging]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add traceDynamic debugging utility

## Description
Debug logging for dynamics. Print dynamic value changes with customizable label/format for debugging reactive networks.

## Progress
- [2026-01-25T02:42:31] Closed: Implemented Dynamic.traceM and Dynamic.traceWithM in Host/Spider/Dynamic.lean. Provides debug logging for dynamic value changes with customizable labels and formatters. Also added fluent variants trace' and traceWith'.
