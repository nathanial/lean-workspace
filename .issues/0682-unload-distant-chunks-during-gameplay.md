---
id: 682
title: Unload distant chunks during gameplay
status: open
priority: medium
created: 2026-02-02T05:45:48
updated: 2026-02-02T05:45:48
labels: []
assignee: 
project: cairn
blocks: []
blocked_by: []
---

# Unload distant chunks during gameplay

## Description
main loop requests chunks every frame but never unloads; call unloadDistantChunks periodically to cap memory

