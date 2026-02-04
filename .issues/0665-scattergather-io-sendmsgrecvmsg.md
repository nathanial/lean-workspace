---
id: 665
title: Scatter/gather I/O (sendmsg/recvmsg)
status: closed
priority: low
created: 2026-02-02T04:17:21
updated: 2026-02-03T18:37:40
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Scatter/gather I/O (sendmsg/recvmsg)

## Description
Implement scatter/gather I/O using sendmsg and recvmsg. Allows sending/receiving from multiple buffers in a single call. Part of Phase 9: Advanced Features.

## Progress
- [2026-02-03T18:37:37] Added sendmsg/recvmsg bindings and tests; updated roadmap
- [2026-02-03T18:37:40] Closed: Implemented sendmsg/recvmsg API with tests; lake test OK
