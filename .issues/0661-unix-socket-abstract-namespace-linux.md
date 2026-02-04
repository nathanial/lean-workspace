---
id: 661
title: Unix socket abstract namespace (Linux)
status: closed
priority: low
created: 2026-02-02T04:17:17
updated: 2026-02-03T19:57:46
labels: [unix-sockets]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Unix socket abstract namespace (Linux)

## Description
Add support for Linux abstract namespace Unix sockets (paths starting with null byte). Part of Phase 8: Unix Domain Sockets.

## Progress
- [2026-02-03T19:57:40] Added unixAbstract SockAddr + FFI handling and Linux-only test; updated roadmap
- [2026-02-03T19:57:46] Closed: Implemented abstract Unix namespace support and tests; lake test OK
