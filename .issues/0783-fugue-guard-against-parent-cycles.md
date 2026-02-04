---
id: 783
title: fugue: guard against parent cycles
status: closed
priority: low
created: 2026-02-03T23:49:27
updated: 2026-02-03T23:51:05
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# fugue: guard against parent cycles

## Description
In data/convergent/Convergent/Sequence/Fugue.lean, traverse/isAncestor are partial and can loop if parent pointers form cycles. Add cycle checks or validation on insert/merge to prevent non-termination for malformed ops.

## Progress
- [2026-02-03T23:51:03] Added visited-set guards to traverse/isAncestor to avoid cycles.
- [2026-02-03T23:51:05] Closed: Added visited-set guards to traverse/isAncestor to prevent cycle loops.
