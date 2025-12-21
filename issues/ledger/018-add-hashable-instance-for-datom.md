# Add Hashable Instance for Datom

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Datom` lacks a `Hashable` instance, limiting its use in hash-based collections.

## Rationale
Implement `Hashable` for Datom by combining hashes of its components.

Benefits:
- Enable use in HashMap/HashSet
- Performance improvement for certain operations
- More flexible data structure options

## Affected Files
- `Ledger/Core/Datom.lean`
