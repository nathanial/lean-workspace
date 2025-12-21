# ReaderT/StateT Optic Integration

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Extend `Collimator/Integration.lean` with monad transformer zoom patterns that work seamlessly with Lean 4's effect system.

## Rationale
The current `Integration.lean` provides basic `StateM` and `ReaderM` utilities. More sophisticated patterns like nested zoom and optic-based `local` would improve ergonomics in monadic code.

## Affected Files
- Modify: `Collimator/Integration.lean`
- Add examples and tests
