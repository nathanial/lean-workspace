---
id: 532
title: Add Docstrings to Inductive Constructors
status: open
priority: medium
created: 2026-01-31T00:10:18
updated: 2026-01-31T00:10:18
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Add Docstrings to Inductive Constructors

## Description
Inductive types like Value, TxOp, PullPattern, Clause have constructor documentation in some cases but not all. Add docstrings to all constructors explaining their purpose with usage examples. Files: Core/Value.lean, Tx/Types.lean, Pull/Pattern.lean, Query/AST.lean. Small effort.

