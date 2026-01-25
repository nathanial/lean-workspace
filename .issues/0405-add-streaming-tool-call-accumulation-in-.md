---
id: 405
title: add streaming tool-call accumulation in core client
status: closed
priority: medium
created: 2026-01-25T01:57:30
updated: 2026-01-25T02:52:32
labels: []
assignee: 
project: oracle
blocks: []
blocked_by: []
---

# add streaming tool-call accumulation in core client

## Description
StreamChunk parses tool_call deltas but core streaming client lacks an accumulator; add StreamAccumulator/collectToolCalls utilities outside the reactive layer (Oracle/Client/Stream.lean, Oracle/Response/Delta.lean).

## Progress
- [2026-01-25T02:52:32] Closed: Added StreamAccumulator and collectToolCalls helpers in core streaming client with tests (commit 4d29872).
