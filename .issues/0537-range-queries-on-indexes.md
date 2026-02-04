---
id: 537
title: Range Queries on Indexes
status: closed
priority: low
created: 2026-01-31T00:10:40
updated: 2026-02-04T02:11:28
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Range Queries on Indexes

## Description
Implement true range queries on RBMap indexes instead of filtering. Currently index queries like datomsForEntity iterate entire index and filter (filterMap). RBMap structure supports efficient range queries but not used. Modify: Index/EAVT.lean, AEVT.lean, AVET.lean, VAET.lean. Medium effort.

## Progress
- [2026-02-04T02:11:28] Closed: range queries already use RBRange in all indexes
