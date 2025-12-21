# Margin Collapse Support

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement CSS margin collapsing behavior where adjacent vertical margins combine into a single margin equal to the larger of the two.

## Rationale
Margin collapse is a fundamental CSS behavior that affects vertical spacing between elements.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (new margin collapse logic)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Types.lean` (possibly add `marginCollapse` option)
