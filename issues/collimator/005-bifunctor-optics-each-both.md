# Bifunctor Optics (Each, Both)

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Small
**Dependencies:** None

## Description
Add `each` and `both` combinators for traversing bifunctor structures (tuples, Either-like types).

## Rationale
Common patterns like `(a, a) & both %~ f` are currently not ergonomic. The `Collimator/Instances.lean` has `Prod` lenses but not a unified `both` traversal.

## Affected Files
- Modify: `Collimator/Instances.lean` (add `both` for `Prod`)
- Modify: `Collimator/Combinators.lean` (add generic `each` if possible)
- Add tests
