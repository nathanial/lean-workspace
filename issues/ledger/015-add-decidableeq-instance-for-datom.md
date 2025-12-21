# Add DecidableEq Instance for Datom

**Priority:** High
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
`Datom` only has a `BEq` instance but not `DecidableEq`. This limits its use in proofs and some library functions.

## Rationale
Add `deriving DecidableEq` to the Datom structure or implement the instance manually.

Benefits:
- Enable use with more Batteries/mathlib functions
- Support for proofs about datom equality
- Better Lean 4 idiom compliance

## Affected Files
- `Ledger/Core/Datom.lean` (line 28)
