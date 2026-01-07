---
id: 127
title: Add day of year and week number support
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

# Add day of year and week number support

## Description
Add day-of-year (1-366) and week number information. Useful for date calculations, fiscal calendars, ISO week numbering. API: DateTime.dayOfYear, DateTime.weekOfYear, DateTime.isoWeek. Uses tm_yday from struct tm.

## Progress
- [2026-01-07T00:08:44] Closed: Already implemented: dayOfYear and weekOfYear functions with FFI support
