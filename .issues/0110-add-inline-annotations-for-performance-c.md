---
id: 110
title: Add @[inline] Annotations for Performance-Critical Functions
status: open
priority: low
created: 2026-01-06T23:28:57
updated: 2026-01-06T23:28:57
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Add @[inline] Annotations for Performance-Critical Functions

## Description
Many small helper functions like AxisInfo.mainSize, EdgeInsets.horizontal are not annotated for inlining. Add @[inline] or @[always_inline] to frequently-called small functions in Axis.lean and Types.lean. Effort: Small

