---
id: 773
title: Expose more socket options
status: closed
priority: medium
created: 2026-02-03T23:46:52
updated: 2026-02-04T02:11:17
labels: []
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Expose more socket options

## Description
Add wrappers for SO_ERROR, keepalive tuning (TCP_KEEPIDLE/KEEPINTVL/KEEPCNT), and sub-second recv/send timeouts.

## Progress
- [2026-02-04T02:11:17] Closed: Added keepalive tuning and millisecond timeout setters
