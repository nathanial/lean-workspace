# Getter and Review Optic Types

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add explicit `Getter` and `Review` optic types to complement the existing hierarchy. Currently, read-only access uses `Fold` and construction uses prisms, but dedicated types would improve clarity and type inference.

## Rationale
The optic hierarchy is nearly complete but missing these two important types. `Getter s a` is a read-only lens, and `Review t b` is a write-only prism. Having these would complete the subtyping lattice shown in the tracing/command output.

## Affected Files
- Modify: `Collimator/Optics.lean` (add `Getter`, `Review` structures)
- Modify: `Collimator/Combinators.lean` (add conversion functions)
- Modify: `Collimator/Exports.lean` (re-export)
- New: `CollimatorTests/GetterReviewTests.lean`
