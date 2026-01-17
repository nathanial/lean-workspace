---
id: 380
title: Add Event.buffer combinator
status: closed
priority: medium
created: 2026-01-17T09:41:45
updated: 2026-01-17T11:42:57
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.buffer combinator

## Description
Collect N events before emitting them as a batch. Useful for batch processing patterns.

## Progress
- [2026-01-17T11:42:57] Closed: Added buffer combinator that collects n events before emitting as Array. Includes bufferM/buffer' and 3 tests.
