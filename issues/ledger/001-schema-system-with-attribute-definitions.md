# Schema System with Attribute Definitions

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Implement a schema system allowing attributes to be declared with types, cardinality, uniqueness constraints, and indexing preferences.

## Rationale
Currently Ledger is schema-free which provides flexibility but lacks type safety, cardinality enforcement (one vs. many), uniqueness constraints, and the ability to optimize indexes for specific attributes. A schema system would enable:
- Compile-time type checking for attribute values
- Cardinality validation (`:db.cardinality/one` vs `:db.cardinality/many`)
- Unique value constraints (`:db.unique/identity`, `:db.unique/value`)
- Component relationships for cascading operations
- Better query optimization through attribute metadata

## Affected Files
- New file: `Ledger/Schema/Types.lean`
- New file: `Ledger/Schema/Validation.lean`
- Modify: `Ledger/Db/Database.lean` (add schema to Db structure)
- Modify: `Ledger/Tx/Types.lean` (add schema validation errors)
- Modify: `Ledger/DSL/TxBuilder.lean` (add schema-aware builders)
