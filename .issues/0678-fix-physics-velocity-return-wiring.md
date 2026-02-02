---
id: 678
title: Fix physics velocity return wiring
status: closed
priority: high
created: 2026-02-02T05:45:33
updated: 2026-02-02T05:46:58
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Fix physics velocity return wiring

## Description
updatePlayer returns (newVx,newVy,newVz,finalVy) but caller treats finalVy as velocityZ; fix return tuple and use post-collision Y velocity

## Progress
- [2026-02-02T05:46:54] updated updatePlayer to return post-collision Y velocity and proper Z velocity order
- [2026-02-02T05:46:58] Closed: return finalVy as velocityY and restore velocityZ slot
