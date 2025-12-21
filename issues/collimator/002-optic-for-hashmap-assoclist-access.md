# Optic for HashMap/AssocList Access

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Provide `at` and `ix` optics for key-value access, similar to Haskell's `at :: Index m => Index m -> Lens' m (Maybe (IxValue m))` and `ix :: Ixed m => Index m -> Traversal' m (IxValue m)`.

## Rationale
The `examples/JsonLens.lean` manually implements `field` and `index` as `AffineTraversal'`. These patterns are common enough to warrant first-class support with proper abstractions.

## Affected Files
- New: `Collimator/At.lean` or extend `Collimator/Instances.lean`
- Modify: `Collimator/Prelude.lean` (re-export)
- New: Tests for HashMap, AssocList, Array access patterns
