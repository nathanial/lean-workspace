# Improve Error Handling in DSL.withNewEntity

**Priority:** Medium
**Section:** Code Improvements
**Estimated Effort:** Small
**Dependencies:** None

## Description
In `Ledger/DSL/TxBuilder.lean`, the `withNewEntity` function silently returns a dummy TxReport on error instead of propagating the error.

## Rationale
Return `Except TxError (Db × EntityId × TxReport)` or use the Except monad properly.

Benefits:
- Proper error handling
- No silent failures
- Consistent API design

## Affected Files
- `Ledger/DSL/TxBuilder.lean` (lines 134-140)
