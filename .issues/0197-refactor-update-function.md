---
id: 197
title: Refactor Update Function
status: open
priority: medium
created: 2026-01-07T01:10:02
updated: 2026-01-07T01:10:02
labels: [improvement]
assignee: 
project: enchiridion
blocks: []
blocked_by: []
---

# Refactor Update Function

## Description
The update function in UI/Update.lean is a large chain of if-else statements that is difficult to maintain. Consider pattern matching or command pattern to decouple key handling from actions.

