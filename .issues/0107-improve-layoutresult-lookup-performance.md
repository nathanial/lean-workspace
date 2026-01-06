---
id: 107
title: Improve LayoutResult Lookup Performance
status: open
priority: medium
created: 2026-01-06T23:28:57
updated: 2026-01-06T23:28:57
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Improve LayoutResult Lookup Performance

## Description
LayoutResult.get uses Array.find? which is O(n) lookup. Use a HashMap NodeId ComputedLayout or maintain sorted array for binary search. O(1) or O(log n) lookups instead of O(n) for large layout trees. Affected files: Result.lean. Effort: Small

