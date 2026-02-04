---
id: 523
title: Transaction Functions
status: closed
priority: medium
created: 2026-01-31T00:09:51
updated: 2026-02-03T19:50:44
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Transaction Functions

## Description
Allow custom functions to run within transactions for complex multi-step operations with validation. Enables increment/decrement operations, compare-and-swap patterns, custom validation logic, conditional transactions. New file: Ledger/Tx/Functions.lean. Modify: Tx/Types.lean, Db/Database.lean. Large effort.

## Progress
- [2026-02-03T19:50:44] Closed: implemented tx functions with built-in cas/inc, registry expansion, and full tests
