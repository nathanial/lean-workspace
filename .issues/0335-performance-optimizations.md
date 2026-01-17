---
id: 335
title: Performance Optimizations
status: closed
priority: low
created: 2026-01-09T08:12:04
updated: 2026-01-17T13:11:47
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Performance Optimizations

## Description
Profile and optimize the FRP network for: 1) Reduce allocations in hot paths (event firing, behavior sampling), 2) Batch subscriber notifications when possible, 3) Consider using packed arrays instead of Array (SubscriberId x Subscriber a). Current implementation prioritizes clarity over performance.

## Progress
- [2026-01-17T13:11:47] Closed: Closed by user request
