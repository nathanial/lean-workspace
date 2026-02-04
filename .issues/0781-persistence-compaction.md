---
id: 781
title: Persistence compaction
status: closed
priority: medium
created: 2026-02-03T23:47:39
updated: 2026-02-04T00:38:29
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Persistence compaction

## Description
Add compaction that writes a snapshot and trims/archives journal entries up to snapshot txId. Define safety/atomicity steps and history retention policy.

## Progress
- [2026-02-04T00:38:29] Closed: implemented compaction via snapshot + journal trimming with tests
