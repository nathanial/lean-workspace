# Improve Prism Ergonomics

**Priority:** Medium
**Section:** API Enhancements
**Estimated Effort:** Small
**Dependencies:** None

## Description
The current prism API requires manual splitting into Sum types. Add helper constructors for common patterns.

Proposed Changes:
- Add `prismFromOption : (s -> Option a) -> (a -> s) -> Prism' s a` (already exists as `prismFromPartial`)
- Rename `prismFromPartial` to `prism'` for consistency with Haskell
- Add `only : a -> Prism' a ()` for exact value matching
- Add `nearly : a -> (a -> Bool) -> Prism' a ()` for predicate matching

## Affected Files
- `Collimator/Optics.lean`
- `Collimator/Helpers.lean`
- `Collimator/Exports.lean`
