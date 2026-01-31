---
id: 392
title: Add Dynamic.memoize combinator
status: closed
priority: medium
created: 2026-01-17T09:42:27
updated: 2026-01-31T00:26:50
labels: [performance]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Dynamic.memoize combinator

## Description
Cache expensive dynamic computations. Prevent redundant recomputation when the same dynamic is sampled multiple times.

## Progress
- [2026-01-31T00:20:34] Completed investigation. Identified that memoize should cache computation by input (using BEq on input type), distinct from existing holdUniqDynM/mapUniqM which deduplicate by output. Plan ready.
- [2026-01-31T00:26:50] Closed: Implemented Dynamic.memoizeM and Dynamic.memoize' combinators. Unlike mapUniqM (output-based dedup), memoizeM uses input-based dedup via BEq, skipping computation entirely when input unchanged. Added 4 comprehensive tests covering basic usage, event firing semantics, fluent syntax, and comparison with mapUniqM.
