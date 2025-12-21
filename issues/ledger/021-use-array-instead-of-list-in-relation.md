# Use Array Instead of List in Relation

**Priority:** Low
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Relation` in `Ledger/Query/Binding.lean` uses `List Binding` internally.

## Rationale
Use `Array Binding` for better performance with random access and modifications.

Benefits:
- O(1) random access
- Better cache locality
- More efficient joins

## Affected Files
- `Ledger/Query/Binding.lean` (lines 96-142)
- `Ledger/Query/Executor.lean`
