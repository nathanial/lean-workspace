---
id: 257
title: Extract Cell Rendering to Batched Draw Calls
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

# Extract Cell Rendering to Batched Draw Calls

## Description
Each cell is rendered individually with separate Canvas operations. Batch cells with same background color; use text batching for foreground. Affects: Vane/Render/Grid.lean

