---
id: 339
title: Replace IO.Ref with More Efficient Mutable State
status: open
priority: low
created: 2026-01-09T08:12:05
updated: 2026-01-09T08:12:05
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Replace IO.Ref with More Efficient Mutable State

## Description
Currently uses IO.Ref for all mutable state (subscriber lists, current values). Consider using ST.Ref within an ST region for better performance, or IO.Mutex for thread-safety if concurrent access is needed. Affects Event.lean, Dynamic.lean, and Spider.lean.

