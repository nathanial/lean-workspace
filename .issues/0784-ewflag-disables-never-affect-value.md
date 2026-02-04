---
id: 784
title: ewflag: disables never affect value
status: open
priority: high
created: 2026-02-03T23:49:31
updated: 2026-02-03T23:49:31
labels: []
assignee: 
project: convergent
blocks: []
blocked_by: []
---

# ewflag: disables never affect value

## Description
EWFlag.value ignores disabled set, so any enable makes the flag permanently true. This is 2P behavior, not enable-wins on concurrency. Consider timestamps or observed-remove tags so causal disables can take effect.

