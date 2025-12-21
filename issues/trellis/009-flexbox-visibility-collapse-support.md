# Flexbox `visibility: collapse` Support

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Support the `visibility: collapse` behavior for flex items where the item is hidden but its cross-size contribution to the line is preserved.

## Rationale
Useful for implementing togglable content without layout shifts.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Flex.lean` (add visibility property)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean`
