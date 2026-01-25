---
id: 396
title: Add performEventAsync combinator
status: closed
priority: high
created: 2026-01-17T09:42:41
updated: 2026-01-25T02:40:06
labels: [async]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add performEventAsync combinator

## Description
Async IO execution that doesn't block propagation. Run IO actions in background and emit results as events when complete.

## Progress
- [2026-01-25T02:40:06] Closed: Duplicate - already exists as asyncOnEvent in Reactive/Host/Spider/Async.lean. Use asyncOnEvent to run IO actions in background and emit results as events.
