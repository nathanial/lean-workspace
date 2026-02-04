---
id: 780
title: Persistence snapshots
status: closed
priority: medium
created: 2026-02-03T23:47:36
updated: 2026-02-04T00:36:16
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Persistence snapshots

## Description
Add snapshot serialization/loading to persistence. On startup, load latest snapshot and replay journal tail. Define snapshot format (txId, db state/indexes/currentFacts/nextEntityId/schema), write policy, and file naming.

## Progress
- [2026-02-04T00:36:16] Closed: implemented snapshot persistence with JSON format, tail replay, and tests
