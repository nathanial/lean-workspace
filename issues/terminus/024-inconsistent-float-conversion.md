# Inconsistent Float Conversion

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Various widgets use different patterns for Float to Nat conversion: `toUInt32.toNat`, `Int.ofNat`, direct `.toNat`. This is inconsistent and some conversions may lose precision or behave unexpectedly with negative values.

## Rationale
Define a consistent helper function for Float to Nat conversion, handle negative values explicitly, and apply consistently across all widgets.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/Canvas.lean` (lines 250-275)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/LineChart.lean` (lines 227-230)
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Widgets/BarChart.lean` (line 96)
