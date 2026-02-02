---
id: 650
title: Socket.sendAll - send all bytes with retry loop
status: open
priority: medium
created: 2026-02-02T04:17:03
updated: 2026-02-02T04:17:03
labels: [enhancement]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Socket.sendAll - send all bytes with retry loop

## Description
Implement Socket.sendAll that loops until all bytes are sent. The current Socket.send may return early; sendAll should handle partial sends by retrying until the full buffer is transmitted.

