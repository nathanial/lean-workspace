---
id: 660
title: Async-friendly API design
status: closed
priority: low
created: 2026-02-02T04:17:15
updated: 2026-02-03T04:34:31
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Async-friendly API design

## Description
Design and implement an async-friendly API that integrates well with Lean async runtimes. Build on the existing non-blocking I/O and poll support. Part of Phase 7.

## Progress
- [2026-02-03T04:34:27] Implemented async manager, non-blocking try APIs, and async tests
- [2026-02-03T04:34:31] Closed: Implemented async API, try-FFI, and tests (socket tests blocked by sandbox permissions)
