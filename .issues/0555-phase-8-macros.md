---
id: 555
title: Phase 8: Macros
status: open
priority: low
created: 2026-01-31T01:16:25
updated: 2026-01-31T01:16:25
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 8: Macros

## Description
Implement compound operation macros:

- macro_start_session: Register agent + prepare session in one call
- macro_prepare_thread: Fetch thread + mark all messages read
- macro_file_reservation_cycle: Reserve files + report conflicts
- macro_contact_handshake: Request contact + auto-accept

These combine multiple tool calls into convenient single operations.

Reference: apps/agent-mail/ROADMAP.md lines 62-69

