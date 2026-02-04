---
id: 770
title: Expose send/recv flags
status: closed
priority: medium
created: 2026-02-03T23:46:44
updated: 2026-02-04T01:47:43
labels: []
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Expose send/recv flags

## Description
Support message flags (MSG_PEEK, MSG_DONTWAIT, MSG_NOSIGNAL, MSG_WAITALL, etc.) on send/recv/recvFrom APIs.

## Progress
- [2026-02-04T01:47:43] Closed: Added message-flag constants and flag-aware send/recv APIs
