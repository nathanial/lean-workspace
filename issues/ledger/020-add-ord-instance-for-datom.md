# Add Ord Instance for Datom

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Datom` has comparison functions (`compareEAVT`, etc.) but no `Ord` instance. The indexes use separate key types instead.

## Rationale
Add an `Ord` instance for Datom (perhaps defaulting to EAVT order) to enable direct use in sorted collections.

Benefits:
- Simplify index implementation
- Enable Datom use in sorted containers directly
- Better API ergonomics

## Affected Files
- `Ledger/Core/Datom.lean`
