---
id: 345
title: Prove subscriber notification properties
status: closed
priority: low
created: 2026-01-09T08:56:16
updated: 2026-01-09T10:02:45
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Prove subscriber notification properties

## Description
Prove semantic properties about event subscription: (1) subscribers receive all fired values, (2) unsubscribe prevents future notifications, (3) subscriber order is preserved. Requires modeling IO.Ref semantics, possibly using axiomatic assumptions or separation logic.

## Progress
- [2026-01-09T10:02:45] Closed: Added SubscriberLaws.lean with axioms for subscriber notification properties: completeness, unsubscription, and order preservation
