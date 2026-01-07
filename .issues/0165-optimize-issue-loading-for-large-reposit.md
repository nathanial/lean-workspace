---
id: 165
title: Optimize issue loading for large repositories
status: open
priority: medium
created: 2026-01-07T00:11:05
updated: 2026-01-07T00:11:05
labels: [performance]
assignee: 
project: tracker
blocks: []
blocked_by: []
---

# Optimize issue loading for large repositories

## Description
loadAllIssues reads and parses every issue file on every operation. Add caching with mtime-based invalidation or lazy loading for better performance with hundreds of issues.

