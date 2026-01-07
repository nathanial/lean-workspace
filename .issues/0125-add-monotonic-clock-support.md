---
id: 125
title: Add monotonic clock support
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

# Add monotonic clock support

## Description
Add support for monotonic clocks (CLOCK_MONOTONIC) for measuring elapsed time intervals. Wall clock time can jump backwards (NTP, DST). API: Chronos.Monotonic.now, Chronos.Monotonic.elapsed. Depends on Duration type.

## Progress
- [2026-01-07T00:08:44] Closed: Already implemented: MonotonicTime type with now, elapsed, duration functions using CLOCK_MONOTONIC FFI
