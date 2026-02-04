---
id: 664
title: Socket.sendFile - zero-copy file transfer
status: closed
priority: low
created: 2026-02-02T04:17:20
updated: 2026-02-03T18:47:44
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Socket.sendFile - zero-copy file transfer

## Description
Implement Socket.sendFile for zero-copy file transfer where available (sendfile on Linux, etc.). Part of Phase 9: Advanced Features.

## Progress
- [2026-02-03T18:47:41] Added Socket.sendFile binding + sendfile/loop fallback and tests; updated roadmap
- [2026-02-03T18:47:44] Closed: Implemented Socket.sendFile with sendfile/fallback and tests; lake test OK
