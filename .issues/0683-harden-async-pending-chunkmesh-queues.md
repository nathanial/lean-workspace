---
id: 683
title: Harden async pending chunk/mesh queues
status: open
priority: medium
created: 2026-02-02T05:45:51
updated: 2026-02-02T05:45:51
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Harden async pending chunk/mesh queues

## Description
pendingChunks/pendingMeshes are IO.Ref Arrays mutated from multiple tasks; use a thread-safe queue or mutex to prevent lost updates

