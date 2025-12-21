# Improve Type Inference with Optic Subtyping

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The `Collimator/Theorems/Subtyping.lean` file defines coercion functions between optic types, but type inference can still be challenging in some compositions.

## Rationale
Add more `Coe` instances and potentially use Lean 4's instance priorities to improve automatic subtyping. Consider adding helper functions that guide type inference.

Better ergonomics, less explicit type annotation needed.

## Affected Files
- `Collimator/Theorems/Subtyping.lean`
- `Collimator/Combinators.lean` (add inference helpers)
