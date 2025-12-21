# Use Type Aliases for Clarity

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some types could benefit from clearer aliases:
- `List TxOp` is abbreviated to `Transaction` - good
- `List Datom` is not aliased - could be `DatomSeq` or similar
- `List (Attribute x PullValue)` repeated in Pull code

## Rationale
Introduce type aliases for commonly used compound types. Update usage sites.

## Affected Files
- `Ledger/Core/Datom.lean`
- `Ledger/Pull/Result.lean`
