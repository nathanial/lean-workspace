# Predicate Expressions in Queries

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add support for predicate expressions in where clauses like `[(> ?age 21)]`, `[(= ?status "active")]`.

## Rationale
The README shows predicate syntax but the current implementation in `Query/AST.lean` only supports pattern matching. Predicates would enable:
- Comparisons: `>`, `<`, `>=`, `<=`, `=`, `!=`
- String operations: `contains`, `starts-with`, `ends-with`
- Arithmetic: `+`, `-`, `*`, `/`
- Boolean logic: `and`, `or`, `not`

## Affected Files
- Modify: `Ledger/Query/AST.lean` (add predicate clause type)
- New file: `Ledger/Query/Predicate.lean`
- Modify: `Ledger/Query/Executor.lean` (evaluate predicates)
- Modify: `Ledger/DSL/QueryBuilder.lean` (add predicate builders)
