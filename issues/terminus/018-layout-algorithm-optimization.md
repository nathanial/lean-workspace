# Layout Algorithm Optimization

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The layout algorithm in `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Layout/Layout.lean` recalculates constraints on every split.

## Rationale
Cache constraint calculations and implement incremental layout updates.

Better performance for complex nested layouts.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Layout/Layout.lean`
- `/Users/Shared/Projects/lean-workspace/terminus/Terminus/Layout/Constraint.lean`
