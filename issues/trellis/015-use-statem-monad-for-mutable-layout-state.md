# Use StateM Monad for Mutable Layout State

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Layout algorithms use `Id.run do` with explicit `let mut` patterns for mutable state.

Proposed change: Consider using `StateM` or `StateT` for cleaner accumulation patterns, especially in grid auto-placement and track sizing.

## Rationale
More idiomatic Lean 4 code, easier to compose with other effects if needed.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/trellis/Trellis/Algorithm.lean`
