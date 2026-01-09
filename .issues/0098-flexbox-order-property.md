---
id: 98
title: Flexbox order Property
status: closed
priority: medium
created: 2026-01-06T23:28:38
updated: 2026-01-09T01:28:42
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Flexbox order Property

## Description
Add support for the CSS order property that allows reordering flex items visually without changing the DOM order. Add order field to FlexItem in Flex.lean, sort items by order before layout in Algorithm.lean. Effort: Small

## Progress
- [2026-01-09T01:28:42] Closed: Implemented CSS order property for flex items. Added order field to FlexItem, sourceIndex to FlexItemState for stable sorting, and sorting logic in layoutFlexContainer. Items are visually reordered by order value while preserving source order for equal values. Added 3 tests. All 130 tests pass.
