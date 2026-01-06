---
id: 64
title: Buffer Diff Optimization
status: open
priority: medium
created: 2026-01-06T22:46:10
updated: 2026-01-06T22:46:10
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Buffer Diff Optimization

## Description
The diff function in Buffer.lean iterates through all cells but could be optimized for common patterns. Implement dirty region tracking or use a more efficient diffing algorithm (e.g., row-level checksums). Reduces rendering overhead for large terminals.

