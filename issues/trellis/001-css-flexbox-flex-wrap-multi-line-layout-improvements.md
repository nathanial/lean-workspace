# CSS Flexbox `flex-wrap` Multi-line Layout Improvements

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The current `flex-wrap` implementation handles basic wrapping but lacks full CSS specification compliance. Items that wrap should properly recalculate line breaks when items shrink, and `wrap-reverse` should reverse the cross-axis direction of lines.

## Rationale
Multi-line flex layouts are common in responsive designs, and accurate wrapping behavior is essential for real-world use cases.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (lines 239-280, `partitionIntoLines`)
