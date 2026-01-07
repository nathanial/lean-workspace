---
id: 126
title: Add day of week support
status: closed
priority: medium
created: 2026-01-07T00:01:44
updated: 2026-01-07T00:08:44
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add day of week support

## Description
Add day-of-week information to DateTime. Common use case for calendaring/scheduling. API: Weekday inductive type, DateTime.weekday, DateTime.isWeekend, DateTime.isWeekday. Uses tm_wday from struct tm.

## Progress
- [2026-01-07T00:08:44] Closed: Already implemented: Weekday inductive type with weekday, isWeekend, isWeekday functions and FFI support
