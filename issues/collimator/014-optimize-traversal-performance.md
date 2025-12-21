# Optimize Traversal Performance

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Traversals create intermediate structures when composing multiple traversals. For example, `over' (t1 . t2) f` may not fuse efficiently.

## Rationale
Add fusion rules or use stream fusion techniques to optimize composed traversals. Consider adding `@[inline]` and `@[specialize]` attributes strategically.

Better runtime performance for complex optic compositions.

## Affected Files
- `Collimator/Optics.lean`
- `Collimator/Combinators.lean`
