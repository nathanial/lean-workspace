---
id: 667
title: Out-of-band data support
status: closed
priority: low
created: 2026-02-02T04:17:23
updated: 2026-02-03T19:40:08
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Out-of-band data support

## Description
Add support for TCP out-of-band (urgent) data using MSG_OOB flag. Part of Phase 9: Advanced Features.

## Progress
- [2026-02-03T19:40:03] Added sendOob/recvOob with MSG_OOB, tests, and marked roadmap complete
- [2026-02-03T19:40:08] Closed: Implemented out-of-band send/recv with MSG_OOB and tests; lake test OK
