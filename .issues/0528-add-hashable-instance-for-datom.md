---
id: 528
title: Add Hashable Instance for Datom
status: closed
priority: medium
created: 2026-01-31T00:10:08
updated: 2026-02-03T20:17:54
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Add Hashable Instance for Datom

## Description
Datom lacks a Hashable instance, limiting use in hash-based collections. Implement Hashable for Datom by combining hashes of its components. Enables HashMap/HashSet usage, performance improvement. Ledger/Core/Datom.lean. Small effort.

## Progress
- [2026-02-03T20:17:54] Closed: added Hashable instance for Datom
