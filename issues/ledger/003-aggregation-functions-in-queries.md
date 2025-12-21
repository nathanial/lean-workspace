# Aggregation Functions in Queries

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Add support for aggregate functions like `count`, `sum`, `avg`, `min`, `max` in queries.

## Rationale
The query engine currently only supports pattern matching and returns raw bindings. Aggregation is essential for analytics.

## Affected Files
- Modify: `Ledger/Query/AST.lean` (add aggregate clause)
- New file: `Ledger/Query/Aggregates.lean`
- Modify: `Ledger/Query/Executor.lean` (process aggregates)
- Modify: `Ledger/DSL/QueryBuilder.lean` (add aggregate builders)
