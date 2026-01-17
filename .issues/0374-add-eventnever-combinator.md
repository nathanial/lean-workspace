---
id: 374
title: Add Event.never combinator
status: closed
priority: low
created: 2026-01-17T09:41:44
updated: 2026-01-17T11:09:38
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.never combinator

## Description
Empty event that never fires. Useful as identity for merge operations and placeholder events.

## Progress
- [2026-01-17T11:09:38] Closed: Implemented in commit 4f6c37f. Added neverM/never' to Spider.lean (pure IO version already existed in Core).
