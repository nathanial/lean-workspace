---
id: 124
title: Add DateTime calendar-aware arithmetic
status: closed
priority: high
created: 2026-01-07T00:01:29
updated: 2026-01-07T00:08:44
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add DateTime calendar-aware arithmetic

## Description
Add functions to perform calendar-aware arithmetic on DateTime values: addDays, addMonths, addYears, addHours, addMinutes. Currently users must convert to Timestamp, do arithmetic, and convert back.

## Progress
- [2026-01-07T00:08:44] Closed: Already implemented: addDaysPure, addMonthsPure, addYearsPure, addHoursPure, addMinutesPure, addSecondsPure, addDurationPure with IO wrappers
