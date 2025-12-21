# Add Proper Baseline Alignment

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** Requires text measurement integration

## Description
Baseline alignment for both `AlignItems.baseline` and grid alignment is simplified as `flexStart` with comments indicating this (Flex.lean line 52, Algorithm.lean lines 415-416, 637, 644).

Proposed change: Implement proper baseline calculation based on first text baseline of items.

## Rationale
Correct text alignment across flex items with different font sizes.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Flex.lean`
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean`
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Node.lean` (add baseline info to `ContentSize`)
