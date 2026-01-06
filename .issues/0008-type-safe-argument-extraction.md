---
id: 8
title: Type-safe argument extraction
status: open
priority: high
created: 2026-01-06T14:47:16
updated: 2026-01-06T14:47:16
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# Type-safe argument extraction

## Description
Current extraction uses string-based lookups (result.get "verbose") which is error-prone. Consider phantom types or dependent types for compile-time argument name matching. Affects: Parse/Extractor.lean, Core/Types.lean

