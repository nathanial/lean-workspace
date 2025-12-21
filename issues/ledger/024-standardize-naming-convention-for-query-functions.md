# Standardize Naming Convention for Query Functions

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Inconsistent naming between modules. For example:
- `findByAttrValue` vs `datomsForAttrValue`
- `entitiesWithAttr` vs `findEntitiesWith`

## Rationale
Establish naming convention (verb-first vs noun-first), rename functions for consistency, and add deprecation aliases for backward compatibility.

## Affected Files
- `Ledger/Db/Database.lean`
- `Ledger/DSL/Combinators.lean`
- `Ledger/DSL/QueryBuilder.lean`
