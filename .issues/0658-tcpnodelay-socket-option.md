---
id: 658
title: TCP_NODELAY socket option
status: closed
priority: medium
created: 2026-02-02T04:17:13
updated: 2026-02-02T07:53:15
labels: [socket-options]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# TCP_NODELAY socket option

## Description
Add support for TCP_NODELAY socket option to disable Nagle's algorithm. Important for latency-sensitive applications like interactive protocols.

## Progress
- [2026-02-02T07:52:49] Added TCP_NODELAY helper accessors and tests; updated roadmap and issue order.
- [2026-02-02T07:53:15] Closed: Added TCP_NODELAY helpers with tests and updated roadmap.
