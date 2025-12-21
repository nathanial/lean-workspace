# Rules and Recursive Queries

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement Datalog rules for defining derived relationships and recursive queries.

## Rationale
Rules would enable powerful graph queries like "find all ancestors" or "compute transitive closure".

## Affected Files
- New file: `Ledger/Query/Rules.lean`
- Modify: `Ledger/Query/AST.lean` (add rule definitions)
- Modify: `Ledger/Query/Executor.lean` (implement rule evaluation)
