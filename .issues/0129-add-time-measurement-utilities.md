---
id: 129
title: Add time measurement utilities
status: closed
priority: medium
created: 2026-01-07T00:01:45
updated: 2026-01-07T00:08:44
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Add time measurement utilities

## Description
Add convenience functions for timing code execution. API: Chronos.time (returns result and duration), Chronos.benchmark (average over N runs). Depends on Duration type and Monotonic clock.

## Progress
- [2026-01-07T00:08:44] Closed: Already implemented: time, timeOnly, and benchmark functions in Chronos.Monotonic using monotonic clock
