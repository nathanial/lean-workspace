# Transaction Functions

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Allow custom functions to run within transactions for complex multi-step operations with validation.

## Rationale
Datomic supports transaction functions that can read current database state and produce operations atomically. This enables:
- Increment/decrement operations
- Compare-and-swap patterns
- Custom validation logic
- Conditional transactions

## Affected Files
- New file: `Ledger/Tx/Functions.lean`
- Modify: `Ledger/Tx/Types.lean` (add function invocation TxOp)
- Modify: `Ledger/Db/Database.lean` (execute transaction functions)
