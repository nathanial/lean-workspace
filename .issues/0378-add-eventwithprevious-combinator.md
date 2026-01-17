---
id: 378
title: Add Event.withPrevious combinator
status: closed
priority: high
created: 2026-01-17T09:41:45
updated: 2026-01-17T11:34:42
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.withPrevious combinator

## Description
Emit (previous, current) pairs on each event occurrence. Very useful for detecting changes and computing deltas.

## Progress
- [2026-01-17T11:34:42] Closed: Added withPrevious combinator that emits (previous, current) pairs. Skips first occurrence. Includes withPreviousM/withPrevious' in SpiderM and 3 tests.
