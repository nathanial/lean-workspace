---
id: 371
title: Add Event.sample/snapshot combinator
status: closed
priority: medium
created: 2026-01-17T09:41:43
updated: 2026-01-17T10:38:22
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.sample/snapshot combinator

## Description
Sample behavior at event occurrence without attaching the value. Unlike attach/tag, this is a pure sampling operation.

## Progress
- [2026-01-17T10:38:22] Closed: Added Event.sample/sampleWithId/sampleM/sample' as aliases for tag variants, and Event.snapshot/snapshotWithId/snapshotM/snapshot' as aliases for attach variants. All 269 tests pass including 6 new tests for the aliases.
