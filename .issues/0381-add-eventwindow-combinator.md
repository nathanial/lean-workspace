---
id: 381
title: Add Event.window combinator
status: closed
priority: medium
created: 2026-01-17T09:41:46
updated: 2026-01-17T11:53:00
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.window combinator

## Description
Collect events within a time window and emit as batch. Useful for time-based aggregation.

## Progress
- [2026-01-17T11:53:00] Closed: Added window combinator for time-based event batching. Uses tumbling windows with Chronos.Duration. Includes windowM/window' and 2 tests.
