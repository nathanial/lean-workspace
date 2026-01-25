---
id: 339
title: Replace IO.Ref with More Efficient Mutable State
status: closed
priority: low
created: 2026-01-09T08:12:05
updated: 2026-01-25T02:17:49
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Replace IO.Ref with More Efficient Mutable State

## Description
Currently uses IO.Ref for all mutable state (subscriber lists, current values). Consider using ST.Ref within an ST region for better performance, or IO.Mutex for thread-safety if concurrent access is needed. Affects Event.lean, Dynamic.lean, and Spider.lean.

## Progress
- [2026-01-25T02:17:49] Closed: Closing as won't fix. Current IO.Ref performance is already good (100 ops in ~2000ns, 1000 subscribers x 100 fires in 5ms). The architectural changes required to switch to ST.Ref would be significant and the performance gains uncertain. The existing implementation handles typical workloads well.
