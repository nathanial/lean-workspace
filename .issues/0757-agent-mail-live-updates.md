---
id: 757
title: agent-mail live updates
status: closed
priority: medium
created: 2026-02-02T22:08:57
updated: 2026-02-03T00:17:10
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# agent-mail live updates

## Description
Add live refresh behavior (polling or SSE) and UI state handling (unread, ack-required, thread updates).

## Progress
- [2026-02-03T00:17:06] Added SSE manager and /app/events/mail endpoint; publish mail events on send/reply/read/ack; UI now listens via EventSource.
- [2026-02-03T00:17:10] Closed: SSE live updates implemented for mail events with UI EventSource integration.
