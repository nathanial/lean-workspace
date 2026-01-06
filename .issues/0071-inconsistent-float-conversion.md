---
id: 71
title: Inconsistent Float Conversion
status: open
priority: medium
created: 2026-01-06T22:46:33
updated: 2026-01-06T22:46:33
labels: [cleanup]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Inconsistent Float Conversion

## Description
Various widgets use different patterns for Float to Nat conversion: toUInt32.toNat, Int.ofNat, direct .toNat. Some conversions may lose precision or behave unexpectedly with negative values. Define a consistent helper function, handle negative values explicitly, apply across all widgets. Location: Terminus/Widgets/Canvas.lean (250-275), LineChart.lean (227-230), BarChart.lean (96)

