# CSS Grid `minmax()` Track Sizing

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
While `TrackSize.minmax` exists in the type definition, the resolution logic in `sizeTracksToContent` only partially handles it. Full implementation should clamp track sizes between minimum and maximum values during both intrinsic sizing and fr-unit distribution phases.

## Rationale
`minmax()` is one of the most commonly used CSS Grid features for responsive layouts.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (lines 521-527, 549-559)
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Grid.lean` (lines 11-16)
