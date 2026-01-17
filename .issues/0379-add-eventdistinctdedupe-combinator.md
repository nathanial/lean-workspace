---
id: 379
title: Add Event.distinct/dedupe combinator
status: closed
priority: high
created: 2026-01-17T09:41:45
updated: 2026-01-17T11:38:23
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.distinct/dedupe combinator

## Description
Skip consecutive duplicate values (requires BEq). Common need to avoid redundant downstream updates when the value hasn't actually changed.

## Progress
- [2026-01-17T11:38:23] Closed: Added distinct/dedupe combinator that skips consecutive duplicates (requires BEq). Includes aliases dedupeM/dedupe' and 3 tests.
