---
id: 219
title: Performance: Avoid intermediate arrays in many
status: open
priority: medium
created: 2026-01-07T03:50:30
updated: 2026-01-07T03:50:30
labels: [performance]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Performance: Avoid intermediate arrays in many

## Description
The many combinator accumulates results into an Array by pushing elements one at a time in a loop.

Proposed: Consider alternative collection strategies or bulk allocation hints for very long sequences.

Benefits:
- Reduced memory allocation overhead for large inputs
- Better cache locality

Affected: Sift/Combinators.lean

Effort: Medium

