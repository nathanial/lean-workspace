---
id: 373
title: Add Event.once combinator
status: closed
priority: low
created: 2026-01-17T09:41:44
updated: 2026-01-17T11:01:12
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.once combinator

## Description
Take only the first occurrence of an event. Specialization of takeN 1 for convenience.

## Progress
- [2026-01-17T11:01:12] Closed: Implemented in commit 033561d. Added once/onceWithId in Event.lean and onceM/once' in Spider.lean as aliases for takeN 1.
