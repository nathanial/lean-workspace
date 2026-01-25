---
id: 388
title: Add Dynamic.foldDynMaybe combinator
status: closed
priority: medium
created: 2026-01-17T09:42:13
updated: 2026-01-25T02:42:32
labels: [dynamic]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Dynamic.foldDynMaybe combinator

## Description
Fold over events but can skip updates by returning none. Useful when not every event should update the state.

## Progress
- [2026-01-25T02:42:32] Closed: Implemented Dynamic.foldDynMaybeM in Host/Spider/Dynamic.lean. Fold over events but only update state when the function returns Some. Also added fluent variant foldDynMaybe'.
