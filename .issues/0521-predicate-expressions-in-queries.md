---
id: 521
title: Predicate Expressions in Queries
status: open
priority: medium
created: 2026-01-31T00:09:47
updated: 2026-01-31T00:09:47
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Predicate Expressions in Queries

## Description
Add support for predicate expressions in where clauses like [(> ?age 21)], [(= ?status "active")]. Enables comparisons (>, <, >=, <=, =, !=), string operations (contains, starts-with, ends-with), arithmetic (+, -, *, /), and boolean logic (and, or, not). New file: Ledger/Query/Predicate.lean. Modify: Query/AST.lean, Query/Executor.lean, DSL/QueryBuilder.lean. Medium effort.

