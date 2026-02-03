---
id: 755
title: agent-mail live data APIs for UI
status: closed
priority: high
created: 2026-02-02T22:08:51
updated: 2026-02-02T22:47:20
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# agent-mail live data APIs for UI

## Description
Expose/extend HTTP resources needed by the live UI (projects, agents, inbox/outbox, threads, message detail). Decide polling vs SSE and add endpoints accordingly.

## Progress
- [2026-02-02T22:25:38] Added thread summary data contract: Storage.Database.ThreadSummary + queryThreadSummaries (project scope, optional agent filter). Added /resource/threads/:project_key handler returning summaries (+ unread_count) with optional include_bodies. Added tests in Tests/Resources/Threads.
- [2026-02-02T22:26:55] Tests: lake test (agent-mail) now passes with new thread resources and tests.
- [2026-02-02T22:47:13] Thread summary + detail resources now used by /app read-only UI; data APIs ready.
- [2026-02-02T22:47:19] Closed: Live UI resources in place (projects, threads, thread detail) and covered by tests.
