---
id: 100
title: Margin Collapse Support
status: closed
priority: medium
created: 2026-01-06T23:28:38
updated: 2026-01-09T01:13:36
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Margin Collapse Support

## Description
Implement CSS margin collapsing behavior where adjacent vertical margins combine into a single margin equal to the larger of the two. New margin collapse logic in Algorithm.lean, possibly add marginCollapse option to Types.lean. Effort: Medium

## Progress
- [2026-01-09T01:13:36] Closed: Implemented CSS margin collapsing support. Added marginCollapse option to FlexContainer, collapseMargins helper function, and updated computeMainPositions to apply collapse logic in column direction. Added 7 comprehensive tests. All 127 tests pass.
