---
id: 780
title: Persistence snapshots
status: open
priority: medium
created: 2026-02-03T23:47:36
updated: 2026-02-03T23:47:36
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Persistence snapshots

## Description
Add snapshot serialization/loading to persistence. On startup, load latest snapshot and replay journal tail. Define snapshot format (txId, db state/indexes/currentFacts/nextEntityId/schema), write policy, and file naming.

