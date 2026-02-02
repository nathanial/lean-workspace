---
id: 680
title: Define negative-Y behavior for BlockPos and blockAt
status: closed
priority: medium
created: 2026-02-02T05:45:40
updated: 2026-02-02T05:54:25
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Define negative-Y behavior for BlockPos and blockAt

## Description
BlockPos.toLocalPos maps y<0 to 0 via toNat; decide on clamping or Option and ensure world/blockAt treat negative Y as air

## Progress
- [2026-02-02T05:54:22] added toLocalPos? and blockAt guard for out-of-range Y; added negative-Y test
- [2026-02-02T05:54:25] Closed: treat out-of-range Y as air via toLocalPos? and blockAt guard
