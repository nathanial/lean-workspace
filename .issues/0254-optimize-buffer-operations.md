---
id: 254
title: Optimize Buffer Operations
status: open
priority: medium
created: 2026-01-07T04:08:09
updated: 2026-01-07T04:08:09
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Optimize Buffer Operations

## Description
Many Buffer operations iterate cell-by-cell with functional updates (scrollUp, scrollRegionUp, fillRect). Use Array.set! in batch operations; consider mutable buffer for hot paths. Affects: Vane/Core/Buffer.lean

