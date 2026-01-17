---
id: 375
title: Add Event.splitE combinator
status: closed
priority: medium
created: 2026-01-17T09:41:44
updated: 2026-01-17T11:12:23
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.splitE combinator

## Description
Split event into two based on a predicate. Cleaner than fanEither when working with boolean conditions rather than Sum types.

## Progress
- [2026-01-17T11:12:23] Closed: Implemented in commit e6acdbb. Added splitEWithId/splitE in Event.lean and splitEM/splitE' in Spider.lean.
