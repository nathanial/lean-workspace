# Indexed Optics

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Add indexed variants of optics that carry position information through the traversal. This would enable operations like `itraversed` that provide both index and value.

## Rationale
Indexed optics are a powerful pattern from Haskell's `lens` library that allows users to access element positions during traversals. The `examples/IndexedOptics.lean` file exists as a placeholder, suggesting this is a desired feature.

## Affected Files
- New: `Collimator/Indexed.lean` or `Collimator/Optics/Indexed.lean`
- New: `Collimator/Indexed/ILens.lean`, `ITraversal.lean`, etc.
- Modify: `Collimator/Instances.lean` (add indexed versions of `traversed`)
- New: `CollimatorTests/IndexedTests.lean`
