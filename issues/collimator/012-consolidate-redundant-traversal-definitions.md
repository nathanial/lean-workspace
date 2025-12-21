# Consolidate Redundant Traversal Definitions

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
Multiple places define traversal-like patterns:
- `List.walkMon` in tests
- `traverseList'Mon` in `Collimator/Theorems/TraversalLaws.lean`
- `traversed` in `Collimator/Instances.lean`

## Rationale
Consolidate to a single canonical implementation with the lawful instance proven once and reused.

Reduces duplication, single source of truth for lawfulness proofs.

## Affected Files
- `Collimator/Instances.lean`
- `Collimator/Theorems/TraversalLaws.lean`
- `CollimatorTests/TraversalTests.lean`
