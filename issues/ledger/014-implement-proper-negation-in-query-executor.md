# Implement Proper Negation in Query Executor

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Medium
**Dependencies:** None

## Description
The query executor in `Ledger/Query/Executor.lean` returns an empty relation for negation (`.not` clause) with a comment "For now, simplified: returns empty (proper impl needs stratification)".

## Rationale
Implement proper negation-as-failure semantics:
- Detect stratification violations (negation in recursive rules)
- Evaluate negated clauses after positive clauses
- Subtract matching bindings from the result

Benefits:
- Enable queries like "find people who are NOT managers"
- Complete Datalog semantics
- Required for many real-world queries

## Affected Files
- `Ledger/Query/Executor.lean` (line 92-95)
- New file: `Ledger/Query/Stratification.lean`
