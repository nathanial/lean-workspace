---
id: 682
title: Unload distant chunks during gameplay
status: closed
priority: medium
created: 2026-02-02T05:45:48
updated: 2026-02-02T22:50:09
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Unload distant chunks during gameplay

## Description
main loop requests chunks every frame but never unloads; call unloadDistantChunks periodically to cap memory

## Progress
- [2026-02-02T22:50:09] Closed: Unload distant chunks on chunk change via FRP state
