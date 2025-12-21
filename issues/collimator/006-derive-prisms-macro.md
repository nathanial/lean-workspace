# Derive Prisms Macro

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add a `makePrisms` command similar to `makeLenses` that automatically generates prisms for inductive type constructors.

## Rationale
The `makeLenses` command in `Collimator/Derive/Lenses.lean` is well-implemented and useful. A corresponding `makePrisms` would complete the derive story for sum types.

## Affected Files
- New: `Collimator/Derive/Prisms.lean`
- Modify: `Collimator/Prelude.lean` (import)
- New: Tests
