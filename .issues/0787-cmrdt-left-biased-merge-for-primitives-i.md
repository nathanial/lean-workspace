---
id: 787
title: cmrdt: left-biased merge for primitives is non-commutative
status: open
priority: medium
created: 2026-02-03T23:49:40
updated: 2026-02-03T23:49:40
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# cmrdt: left-biased merge for primitives is non-commutative

## Description
CmRDT instances for Nat/Int/String/Bool use merge a _ := a, which is not commutative. ORMap merges matching tags via CmRDT.merge, so diverged tagged values can violate CRDT laws. Consider removing these instances or using a commutative merge.

