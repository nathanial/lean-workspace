---
id: 161
title: Consolidate duplicate escapeJson functions
status: open
priority: high
created: 2026-01-07T00:11:05
updated: 2026-01-07T00:11:05
labels: [refactor]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Consolidate duplicate escapeJson functions

## Description
escapeJson function is defined in three places in Types.lean. Move to a shared utility module and reuse across all types for reduced duplication.

