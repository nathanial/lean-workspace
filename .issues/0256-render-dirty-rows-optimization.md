---
id: 256
title: Render Dirty Rows Optimization
status: closed
priority: medium
created: 2026-01-07T04:08:10
updated: 2026-01-07T04:57:54
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Render Dirty Rows Optimization

## Description
renderDirty function exists but appears unused; render always renders all cells. Use renderDirty in the main loop to only re-render changed rows. Affects: Vane/App/Loop.lean

## Progress
- [2026-01-07T04:57:54] Closed: Implemented in commit 8130300 - renderDirty function now uses batched GPU rendering for dirty rows only
