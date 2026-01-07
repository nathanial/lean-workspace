---
id: 122
title: Add Duration type for time spans
status: closed
priority: high
created: 2026-01-07T00:01:29
updated: 2026-01-07T00:04:53
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add Duration type for time spans

## Description
Add a Duration type to represent time spans with nanosecond precision, distinct from Timestamp which represents absolute points in time. Provides type safety, convenient constructors (fromSeconds, fromMinutes), arithmetic operations, and formatting (e.g., '2h 30m 15s'). New file: Chronos/Duration.lean

## Progress
- [2026-01-07T00:04:53] Closed: Already implemented in Chronos/Duration.lean with full feature set: constructors, extractors, arithmetic, comparison, and formatting
