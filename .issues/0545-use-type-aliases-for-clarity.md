---
id: 545
title: Use Type Aliases for Clarity
status: closed
priority: low
created: 2026-01-31T00:11:02
updated: 2026-02-04T02:09:06
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Use Type Aliases for Clarity

## Description
Some types could benefit from clearer aliases. List TxOp is abbreviated to Transaction (good), but List Datom is not aliased (could be DatomSeq). List (Attribute x PullValue) is repeated in Pull code. Introduce type aliases for commonly used compound types. Small effort.

## Progress
- [2026-02-04T02:09:06] Closed: added DatomSeq and PullEntity aliases and applied them in core/pull/time-travel APIs
