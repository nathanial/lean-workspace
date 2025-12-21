# Separate Flexbox and Grid into Distinct Modules

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
All layout algorithms are in a single 959-line `Algorithm.lean` file.

Proposed change: Split into `FlexAlgorithm.lean` and `GridAlgorithm.lean` with shared utilities in a `LayoutUtils.lean` module.

## Rationale
Better separation of concerns, easier navigation, more focused testing.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean` (split into multiple files)
