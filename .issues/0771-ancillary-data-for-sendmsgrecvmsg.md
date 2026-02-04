---
id: 771
title: Ancillary data for sendmsg/recvmsg
status: closed
priority: medium
created: 2026-02-03T23:46:46
updated: 2026-02-04T01:57:50
labels: []
assignee: 
project: jack
blocks: []
blocked_by: []
---

# Ancillary data for sendmsg/recvmsg

## Description
Add control message support for sendmsg/recvmsg (SCM_RIGHTS FD passing, credentials) on Unix sockets.

## Progress
- [2026-02-04T01:57:49] Closed: Added sendmsg/recvmsg control support (SCM_RIGHTS/SCM_CREDENTIALS) with tests
