---
id: 784
title: ewflag: disables never affect value
status: closed
priority: high
created: 2026-02-03T23:49:31
updated: 2026-02-04T00:45:31
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# ewflag: disables never affect value

## Description
EWFlag.value ignores disabled set, so any enable makes the flag permanently true. This is 2P behavior, not enable-wins on concurrency. Consider timestamps or observed-remove tags so causal disables can take effect.

## Progress
- [2026-02-04T00:40:28] Switched EWFlag to timestamp-based last-enable/last-disable tracking with enable-wins on equal times; updated tests and serialization.
- [2026-02-04T00:45:31] Closed: Reworked EWFlag to track last enable/disable timestamps with enable-wins on equal times; updated serialization and tests.
