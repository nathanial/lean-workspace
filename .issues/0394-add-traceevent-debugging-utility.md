---
id: 394
title: Add traceEvent debugging utility
status: closed
priority: high
created: 2026-01-17T09:42:40
updated: 2026-01-25T02:42:31
labels: [debugging]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add traceEvent debugging utility

## Description
Debug logging for events. Print event occurrences with customizable label/format for debugging reactive networks.

## Progress
- [2026-01-25T02:42:31] Closed: Implemented Event.traceM and Event.traceWithM in Host/Spider/Event.lean. Provides debug logging for events with customizable labels and formatters. Also added fluent variants trace' and traceWith'.
