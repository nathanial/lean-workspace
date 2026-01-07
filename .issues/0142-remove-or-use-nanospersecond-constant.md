---
id: 142
title: Remove or use nanosPerSecond constant
status: open
priority: medium
created: 2026-01-07T00:02:31
updated: 2026-01-07T00:02:31
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Remove or use nanosPerSecond constant

## Description
Private constant nanosPerSecond is defined but never used in Timestamp.lean:24. Either remove it or use it in place of hardcoded 1000000000 values.

