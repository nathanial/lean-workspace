---
id: 539
title: Database Statistics and Query Planning
status: open
priority: low
created: 2026-01-31T00:10:45
updated: 2026-01-31T00:10:45
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Database Statistics and Query Planning

## Description
Maintain statistics about data distribution for query optimization. Current query executor orders patterns by selectivity using simple heuristic (bound term count). Enables cardinality estimation, cost-based query planning, adaptive optimization. New file: Ledger/Stats/Statistics.lean. Modify: Query/IndexSelect.lean, Db/Database.lean. Large effort.

