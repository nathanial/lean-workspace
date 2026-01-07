---
id: 256
title: Render Dirty Rows Optimization
status: open
priority: medium
created: 2026-01-07T04:08:10
updated: 2026-01-07T04:08:10
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Render Dirty Rows Optimization

## Description
renderDirty function exists but appears unused; render always renders all cells. Use renderDirty in the main loop to only re-render changed rows. Affects: Vane/App/Loop.lean

