---
id: 73
title: Magic Numbers in Widgets
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

# Magic Numbers in Widgets

## Description
Several widgets contain hardcoded numbers without explanation. Replace magic numbers with named constants and add documentation. Location: LineChart.lean (line 102: height < 3), PieChart.lean (line 55: donut ratio 0.9 max), BarChart.lean (line 141: label width 10)

