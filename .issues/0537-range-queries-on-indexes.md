---
id: 537
title: Range Queries on Indexes
status: open
priority: low
created: 2026-01-31T00:10:40
updated: 2026-01-31T00:10:40
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Range Queries on Indexes

## Description
Implement true range queries on RBMap indexes instead of filtering. Currently index queries like datomsForEntity iterate entire index and filter (filterMap). RBMap structure supports efficient range queries but not used. Modify: Index/EAVT.lean, AEVT.lean, AVET.lean, VAET.lean. Medium effort.

