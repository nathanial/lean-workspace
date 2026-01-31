---
id: 540
title: Use Array Instead of List in Relation
status: open
priority: low
created: 2026-01-31T00:10:47
updated: 2026-01-31T00:10:47
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Use Array Instead of List in Relation

## Description
Relation in Ledger/Query/Binding.lean uses List Binding internally. Use Array Binding for better performance with random access and modifications. O(1) random access, better cache locality, more efficient joins. Small effort.

