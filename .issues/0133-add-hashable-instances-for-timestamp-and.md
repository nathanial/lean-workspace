---
id: 133
title: Add Hashable instances for Timestamp and DateTime
status: closed
priority: high
created: 2026-01-07T00:02:14
updated: 2026-01-07T00:08:44
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add Hashable instances for Timestamp and DateTime

## Description
Timestamp and DateTime derive BEq but lack Hashable instances. Add Hashable to enable use in HashMap and HashSet.

## Progress
- [2026-01-07T00:08:44] Closed: Already implemented: Hashable instances for Timestamp, DateTime, Duration, Weekday, and MonotonicTime
