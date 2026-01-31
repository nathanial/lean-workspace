---
id: 241
title: Window Resize Handling
status: closed
priority: high
created: 2026-01-07T04:06:53
updated: 2026-01-31T00:23:18
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Window Resize Handling

## Description
Implement window resize detection and proper terminal dimension recalculation. handleResize exists in State.lean but is not wired up in the main loop. Affects: Vane/App/Loop.lean, Vane/App/State.lean

## Progress
- [2026-01-31T00:23:12] Wired window resize detection into main loop via getCurrentSize and AppState.handleResize.
- [2026-01-31T00:23:18] Closed: Wire window resize handling in main loop; refresh terminal size from current window size each frame.
