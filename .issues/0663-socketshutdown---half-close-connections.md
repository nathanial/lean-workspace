---
id: 663
title: Socket.shutdown - half-close connections
status: closed
priority: medium
created: 2026-02-02T04:17:19
updated: 2026-02-03T16:37:22
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Socket.shutdown - half-close connections

## Description
Implement Socket.shutdown to allow half-closing TCP connections (shutting down read or write side independently). Part of Phase 9: Advanced Features.

## Progress
- [2026-02-03T16:37:19] Added ShutdownMode, jack_socket_shutdown FFI, Lean binding, and TCP shutdown test
- [2026-02-03T16:37:22] Closed: Implemented Socket.shutdown with FFI + tests; lake build OK
