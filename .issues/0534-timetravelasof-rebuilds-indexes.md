---
id: 534
title: TimeTravel.asOf Rebuilds Indexes
status: open
priority: medium
created: 2026-01-31T00:10:29
updated: 2026-01-31T00:10:29
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# TimeTravel.asOf Rebuilds Indexes

## Description
Connection.asOf in Ledger/Db/Connection.lean (lines 77-91) rebuilds all indexes from scratch by iterating through transaction log and reinserting datoms. O(n) time and memory allocation for every time-travel query. Consider persistent data structures or snapshot caching for common time-travel points. Medium effort.

