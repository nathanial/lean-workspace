---
id: 525
title: Query Macro DSL
status: closed
priority: medium
created: 2026-01-31T00:09:57
updated: 2026-02-03T18:59:48
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Query Macro DSL

## Description
Implement a Lean 4 macro-based DSL for writing queries with syntax closer to Datomic's. Current builder pattern is verbose. Would complement existing makeLedgerEntity macro. New file: Ledger/DSL/Macros.lean. Medium effort.

## Progress
- [2026-02-03T18:59:47] Closed: Implemented query macro DSL with rules, predicates, and tests
