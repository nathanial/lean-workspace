---
id: 552
title: Phase 5: File Reservations
status: closed
priority: medium
created: 2026-01-31T01:16:17
updated: 2026-01-31T06:46:27
labels: []
assignee: 
project: agent-mail
blocks: []
blocked_by: []
---

# Phase 5: File Reservations

## Description
Implement advisory file reservation system:

- file_reservation_paths: Request file reservations with TTL, exclusive flag, reason
- release_file_reservations: Release by paths or reservation IDs
- renew_file_reservations: Extend TTL on reservations
- force_release_file_reservation: Force-release any reservation with reason
- Glob pattern matching for conflict detection (use rune library)

FileReservation model: id, projectId, agentId, pathPattern, exclusive, reason, expiresTs, releasedTs

Reference: apps/agent-mail/ROADMAP.md lines 46-54

## Progress
- [2026-01-31T06:46:27] Closed: Aligned file reservation tools with reference semantics and schemas
