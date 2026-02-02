---
id: 679
title: Dirty neighbor meshes on chunk edge edits
status: closed
priority: high
created: 2026-02-02T05:45:37
updated: 2026-02-02T05:50:45
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Dirty neighbor meshes on chunk edge edits

## Description
when setBlock modifies a boundary block or when a chunk loads, mark adjacent chunks dirty so their meshes update

## Progress
- [2026-02-02T05:50:42] mark neighbor chunks dirty on boundary block edits and when chunks are inserted
- [2026-02-02T05:50:45] Closed: mark neighbor chunks dirty for edge edits and chunk insertion
