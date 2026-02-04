---
id: 787
title: cmrdt: left-biased merge for primitives is non-commutative
status: closed
priority: medium
created: 2026-02-03T23:49:40
updated: 2026-02-04T02:11:16
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# cmrdt: left-biased merge for primitives is non-commutative

## Description
CmRDT instances for Nat/Int/String/Bool use merge a _ := a, which is not commutative. ORMap merges matching tags via CmRDT.merge, so diverged tagged values can violate CRDT laws. Consider removing these instances or using a commutative merge.

## Progress
- [2026-02-04T02:11:11] Changed primitive CmRDT merge to commutative max/OR to ensure deterministic convergence.
- [2026-02-04T02:11:15] Closed: Made primitive CmRDT merges commutative (max/OR) and updated docs; tests pass.
