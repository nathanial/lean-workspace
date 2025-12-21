# Add More Fold Combinators

**Priority:** High
**Section:** API Enhancements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Expand `Fold` operations to include more common patterns from Haskell's lens library.

Current API:
- `toList`, `toListOf`, `foldMap`, `sumOf`, `lengthOf`
- `anyOf`, `allOf`, `firstOf`, `lastOf`

Proposed Additions:
- `findOf` - find first element matching predicate
- `elemOf` - check if element exists
- `nullOf` - check if fold is empty
- `minimumOf`, `maximumOf` - with `Ord` constraint
- `foldl'Of`, `foldr'Of` - strict folds

## Affected Files
- `Collimator/Combinators.lean`
- `Collimator/Exports.lean`
- Tests
