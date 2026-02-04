---
id: 544
title: Consolidate Helper Functions
status: closed
priority: low
created: 2026-01-31T00:10:59
updated: 2026-02-03T23:20:10
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Consolidate Helper Functions

## Description
Some helper functions are duplicated or similar across modules: filterVisible in Db/Database.lean vs filterVisibleAt in Db/TimeTravel.lean, sameFact and groupByFact in TimeTravel.lean could be in Core. Move shared utilities to Ledger/Core/Util.lean. Small effort.

## Progress
- [2026-02-03T23:20:10] Closed: moved shared datom visibility helpers to Core/Util and reused in Database/TimeTravel
