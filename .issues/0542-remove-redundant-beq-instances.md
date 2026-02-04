---
id: 542
title: Remove Redundant BEq Instances
status: closed
priority: low
created: 2026-01-31T00:10:54
updated: 2026-02-04T02:08:59
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Remove Redundant BEq Instances

## Description
Several types derive DecidableEq but also define explicit BEq instances that are equivalent. Examples: EntityId (Core/EntityId.lean lines 19-20), Attribute (Core/Attribute.lean lines 19-20), key types in Index/Types.lean. Remove redundant instances. Small effort.

## Progress
- [2026-02-04T02:08:59] Closed: removed redundant BEq instances; added DecidableEq derivations for index keys
