---
id: 404
title: make stepAgent single-iteration or rename
status: closed
priority: low
created: 2026-01-25T01:57:25
updated: 2026-01-25T02:51:10
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# make stepAgent single-iteration or rename

## Description
stepAgent currently runs the full loop to completion; implement true single-iteration semantics or rename to avoid misleading API (Oracle/Agent/Loop.lean).

## Progress
- [2026-01-25T02:51:10] Closed: Implemented true single-step behavior for stepAgent and added tests (commit 4d29872).
