---
id: 546
title: Missing Test Coverage
status: closed
priority: low
created: 2026-01-31T00:11:04
updated: 2026-02-04T02:02:01
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Missing Test Coverage

## Description
Some features lack test coverage: OR clauses in queries, limited pull patterns, TxError handling, edge cases in time-travel (empty history, single transaction). Add comprehensive tests for all query clause types and edge cases. Medium effort.

## Progress
- [2026-02-04T02:02:01] Closed: added missing coverage for tx errors and time-travel edge cases
