---
id: 26
title: Log-aware progress
status: open
priority: low
created: 2026-01-06T14:48:37
updated: 2026-01-06T14:50:38
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: [24]
---

# Log-aware progress

## Description
Progress bars that handle interleaved log output without corruption. Coordinated output manager prevents garbled output. Depends on threading support. New file: Output/OutputManager.lean

