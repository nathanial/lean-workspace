---
id: 530
title: Add Ord Instance for Datom
status: closed
priority: medium
created: 2026-01-31T00:10:13
updated: 2026-02-03T20:17:52
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Add Ord Instance for Datom

## Description
Datom has comparison functions (compareEAVT, etc.) but no Ord instance. Indexes use separate key types instead. Add Ord instance for Datom (defaulting to EAVT order) to enable direct use in sorted collections. Ledger/Core/Datom.lean. Small effort.

## Progress
- [2026-02-03T20:17:52] Closed: added Ord instance for Datom using EAVT ordering
