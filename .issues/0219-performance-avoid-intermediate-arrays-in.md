---
id: 219
title: Performance: Avoid intermediate arrays in many
status: closed
priority: medium
created: 2026-01-07T03:50:30
updated: 2026-01-25T01:46:14
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

## Progress
- [2026-01-25T01:46:14] Closed: Fixed many1 to build array incrementally instead of using #[first] ++ rest which created an intermediate array. The many combinator was already efficient (Array.push is amortized O(1)). Bulk allocation hints would have diminishing returns.
