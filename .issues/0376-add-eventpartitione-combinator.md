---
id: 376
title: Add Event.partitionE combinator
status: closed
priority: medium
created: 2026-01-17T09:41:45
updated: 2026-01-17T11:31:42
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.partitionE combinator

## Description
Like splitE but returns a pair of events (matching, non-matching) rather than requiring separate calls.

## Progress
- [2026-01-17T11:31:42] Closed: Added partitionE/partitionEM/partitionE' as aliases for splitE with Haskell-style naming. Includes 2 tests.
