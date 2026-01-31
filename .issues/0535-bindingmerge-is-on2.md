---
id: 535
title: Binding.merge is O(n^2)
status: open
priority: medium
created: 2026-01-31T00:10:31
updated: 2026-01-31T00:10:31
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Binding.merge is O(n^2)

## Description
The merge function in Ledger/Query/Binding.lean (lines 79-83) does linear lookup for each entry being merged, resulting in O(n*m) complexity. Slows query execution for queries with many variables. Use a hash-based map for bindings instead of association list. Medium effort.

