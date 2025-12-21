# Remove Partial Annotations in Pull Executor

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The `pullNestedEntity` and `pullPatternRec` functions in `Ledger/Pull/Executor.lean` are marked as `partial`. While cycle detection and depth limits prevent infinite recursion at runtime, the Lean type system cannot verify termination.

## Rationale
- Use fuel-based recursion with a Nat counter
- Or restructure to use `decreasing_by` with well-founded recursion on visited set size

Benefits:
- Remove `partial` annotation
- Total functions are easier to reason about
- Better for potential formal verification

## Affected Files
- `Ledger/Pull/Executor.lean` (lines 84-146)
