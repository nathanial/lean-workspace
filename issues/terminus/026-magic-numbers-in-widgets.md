# Magic Numbers in Widgets

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Several widgets contain hardcoded numbers without explanation.

## Rationale
Replace magic numbers with named constants and add documentation explaining the rationale for each value.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/LineChart.lean` (line 102: `height < 3`)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/PieChart.lean` (line 55: donut ratio 0.9 max)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/BarChart.lean` (line 141: label width 10)
