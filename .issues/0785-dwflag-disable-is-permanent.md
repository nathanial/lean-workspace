---
id: 785
title: dwflag: disable is permanent
status: open
priority: high
created: 2026-02-03T23:49:34
updated: 2026-02-03T23:49:34
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# dwflag: disable is permanent

## Description
DWFlag uses grow-only disabled set; value requires disabled to be empty, so any disable makes the flag permanently false. This is 2P behavior, not disable-wins on concurrency. Use timestamps or observed-remove tags so causal enables can override.

