# CSS `aspect-ratio` Property

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add support for the CSS `aspect-ratio` property to maintain width-to-height ratios during layout calculation.

## Rationale
Aspect ratio constraints are essential for responsive images, videos, and maintaining consistent proportions.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Types.lean` (add `aspectRatio` to `BoxConstraints`)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (apply aspect ratio during dimension resolution)
