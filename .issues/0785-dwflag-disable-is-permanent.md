---
id: 785
title: dwflag: disable is permanent
status: closed
priority: high
created: 2026-02-03T23:49:34
updated: 2026-02-04T01:50:01
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# dwflag: disable is permanent

## Description
DWFlag uses grow-only disabled set; value requires disabled to be empty, so any disable makes the flag permanently false. This is 2P behavior, not disable-wins on concurrency. Use timestamps or observed-remove tags so causal enables can override.

## Progress
- [2026-02-04T01:49:57] Reworked DWFlag to timestamp-based last-enable/last-disable with disable-wins on equal times; updated serialization and tests.
- [2026-02-04T01:50:01] Closed: Switched DWFlag to timestamp-based last enable/disable; disable wins on equal time, later enable can override; updated serialization/tests.
