---
id: 786
title: lseq: allocateBetween can violate between-neighbors invariant
status: closed
priority: high
created: 2026-02-03T23:49:38
updated: 2026-02-04T01:55:33
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# lseq: allocateBetween can violate between-neighbors invariant

## Description
In data/convergent/Convergent/Sequence/LSEQ.lean, allocateAtDepth appends prefix with site := replica when descending; if lower/upper share pos but differ in site, the new ID can fall outside (lower, upper), breaking ordering. Prefix should preserve neighbor level or otherwise guarantee between-ness.

## Progress
- [2026-02-04T01:55:31] Preserved lower-bound level when descending in LSEQ allocation to keep new IDs between neighbors.
- [2026-02-04T01:55:33] Closed: Preserved lower-bound levels in LSEQ allocation; new IDs stay between neighbors; tests updated/run.
