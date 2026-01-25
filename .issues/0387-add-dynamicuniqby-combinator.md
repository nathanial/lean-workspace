---
id: 387
title: Add Dynamic.uniqBy combinator
status: closed
priority: medium
created: 2026-01-17T09:42:12
updated: 2026-01-25T02:42:32
labels: [dynamic]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Dynamic.uniqBy combinator

## Description
Deduplicate dynamic updates by custom comparison function. More flexible than requiring BEq instance.

## Progress
- [2026-01-25T02:42:31] Closed: Implemented Dynamic.uniqByM in Host/Spider/Dynamic.lean. Deduplicates dynamic updates using a custom comparison function. Also added fluent variant uniqBy'.
