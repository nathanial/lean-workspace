---
id: 73
title: Magic Numbers in Widgets
status: closed
priority: medium
created: 2026-01-06T22:46:33
updated: 2026-01-07T00:56:10
labels: [cleanup]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Magic Numbers in Widgets

## Description
Several widgets contain hardcoded numbers without explanation. Replace magic numbers with named constants and add documentation. Location: LineChart.lean (line 102: height < 3), PieChart.lean (line 55: donut ratio 0.9 max), BarChart.lean (line 141: label width 10)

## Progress
- [2026-01-07T00:56:10] Closed: Added named constants: LineChart.minRenderHeight (3), Calendar.minRenderHeight (3), PieChart.maxDonutRatio (0.9), BarChart.maxLabelWidth (10). Magic numbers now have documented semantic meaning.
