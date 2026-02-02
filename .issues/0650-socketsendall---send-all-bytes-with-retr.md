---
id: 650
title: Socket.sendAll - send all bytes with retry loop
status: closed
priority: medium
created: 2026-02-02T04:17:03
updated: 2026-02-02T04:57:45
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Socket.sendAll - send all bytes with retry loop

## Description
Implement Socket.sendAll that loops until all bytes are sent. The current Socket.send may return early; sendAll should handle partial sends by retrying until the full buffer is transmitted.

## Progress
- [2026-02-02T04:57:42] Implemented Socket.sendAll FFI with retry loop; updated tests and roadmap.
- [2026-02-02T04:57:45] Closed: Added Socket.sendAll with retry loop, wired FFI, updated TCP test and roadmap.
