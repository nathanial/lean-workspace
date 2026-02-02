---
id: 65
title: Layout Algorithm Optimization
status: in-progress
priority: medium
created: 2026-01-06T22:46:10
updated: 2026-02-02T04:05:38
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Layout Algorithm Optimization

## Description
The layout algorithm in Terminus/Layout/Layout.lean recalculates constraints on every split. Cache constraint calculations and implement incremental layout updates. Better performance for complex nested layouts. Affects: Terminus/Layout/Layout.lean, Terminus/Layout/Constraint.lean

## Progress
- [2026-02-02T04:05:38] Completed exploration: Layout.lean computeSizes called on every split with no caching. LayoutEngine.lean recursively computes natural sizes and constraints for each node. Ready to design caching strategy.
