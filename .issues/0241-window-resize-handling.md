---
id: 241
title: Window Resize Handling
status: open
priority: high
created: 2026-01-07T04:06:53
updated: 2026-01-07T04:06:53
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Window Resize Handling

## Description
Implement window resize detection and proper terminal dimension recalculation. handleResize exists in State.lean but is not wired up in the main loop. Affects: Vane/App/Loop.lean, Vane/App/State.lean

