---
id: 527
title: Improve Error Handling in DSL.withNewEntity
status: closed
priority: medium
created: 2026-01-31T00:10:06
updated: 2026-02-04T02:08:55
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Improve Error Handling in DSL.withNewEntity

## Description
In Ledger/DSL/TxBuilder.lean, withNewEntity silently returns a dummy TxReport on error instead of propagating the error. Return Except TxError (Db × EntityId × TxReport) or use Except monad properly. Small effort.

## Progress
- [2026-02-04T02:08:55] Closed: withNewEntity now returns Except and propagates errors; added test
