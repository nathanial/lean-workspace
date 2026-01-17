---
id: 372
title: Add Event.difference combinator
status: closed
priority: medium
created: 2026-01-17T09:41:44
updated: 2026-01-17T10:58:39
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.difference combinator

## Description
Fire when one event occurs but another does not. Useful for 'A but not B' patterns.

## Progress
- [2026-01-17T10:58:39] Closed: Implemented in commit 7378a0a. Added differenceWithId/difference in Event.lean and differenceM/difference' in Spider.lean with 4 tests.
