---
id: 772
title: Multicast and broadcast UDP support
status: closed
priority: medium
created: 2026-02-03T23:46:49
updated: 2026-02-04T02:05:59
labels: []
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Multicast and broadcast UDP support

## Description
Expose SO_BROADCAST and IP_ADD_MEMBERSHIP/IPV6_JOIN_GROUP plus TTL/hop-limit and loopback options.

## Progress
- [2026-02-04T02:05:59] Closed: Added multicast/broadcast socket options and join/leave APIs with tests
