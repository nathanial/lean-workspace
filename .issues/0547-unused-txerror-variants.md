---
id: 547
title: Unused TxError Variants
status: closed
priority: low
created: 2026-01-31T00:11:06
updated: 2026-02-04T02:09:02
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Unused TxError Variants

## Description
TxError.invalidEntity is defined but never used in codebase. Location: Ledger/Tx/Types.lean (line 41). Either use the variant for actual validation or remove it. Small effort.

## Progress
- [2026-02-04T02:09:02] Closed: removed unused TxError.invalidEntity and updated docs
