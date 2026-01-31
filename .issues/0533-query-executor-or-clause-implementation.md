---
id: 533
title: Query Executor OR Clause Implementation
status: open
priority: medium
created: 2026-01-31T00:10:26
updated: 2026-01-31T00:10:26
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Query Executor OR Clause Implementation

## Description
The .or clause implementation in Ledger/Query/Executor.lean (lines 89-91) simply concatenates results without proper handling of variable scoping or deduplication across branches. Causes potential duplicate results and unexpected variable binding behavior. Implement proper union semantics with deduplication based on find variables. Medium effort.

