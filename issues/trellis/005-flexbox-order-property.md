# Flexbox `order` Property

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add support for the CSS `order` property that allows reordering flex items visually without changing the DOM order.

## Rationale
The `order` property is commonly used for responsive designs where visual order differs from source order.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Flex.lean` (add `order` field to `FlexItem`)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (sort items by order before layout)
