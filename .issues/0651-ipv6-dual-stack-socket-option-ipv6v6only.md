---
id: 651
title: IPv6 dual-stack socket option (IPV6_V6ONLY)
status: closed
priority: medium
created: 2026-02-02T04:17:05
updated: 2026-02-02T05:53:30
labels: [ipv6]
assignee: 
project: jack
blocks: []
blocked_by: []
---

# IPv6 dual-stack socket option (IPV6_V6ONLY)

## Description
Add support for the IPV6_V6ONLY socket option to control whether IPv6 sockets accept only IPv6 connections or also IPv4-mapped addresses. Part of Phase 5: IPv6 Support.

## Progress
- [2026-02-02T05:53:24] Added IPV6_V6ONLY constants and IPv6-only helpers with option UInt32 accessors.
- [2026-02-02T05:53:30] Closed: Implemented IPV6_V6ONLY constants and IPv6-only helpers with UInt32 option accessors.
