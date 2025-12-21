# Query Macro DSL

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement a Lean 4 macro-based DSL for writing queries with syntax closer to Datomic's.

## Rationale
The current builder pattern is verbose. A macro DSL would provide cleaner syntax.

## Affected Files
- New file: `Ledger/DSL/Macros.lean`
- Modify: `Ledger.lean` (export macro)
