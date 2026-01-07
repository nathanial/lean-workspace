---
id: 142
title: Remove or use nanosPerSecond constant
status: closed
priority: medium
created: 2026-01-07T00:02:31
updated: 2026-01-07T00:48:20
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Remove or use nanosPerSecond constant

## Description
Private constant nanosPerSecond is defined but never used in Timestamp.lean:24. Either remove it or use it in place of hardcoded 1000000000 values.

## Progress
- [2026-01-07T00:48:20] Closed: Changed nanosPerSecond from UInt32 to Int and used it in toNanoseconds and fromNanoseconds instead of hardcoded 1000000000
