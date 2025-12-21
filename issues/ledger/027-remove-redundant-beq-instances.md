# Remove Redundant BEq Instances

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Several types derive `DecidableEq` but also define explicit `BEq` instances that are equivalent. For example, `EntityId` derives both `DecidableEq` and defines a `BEq` instance.

## Rationale
Remove redundant `BEq` instances where `DecidableEq` is derived. Or remove `DecidableEq` derivation if only `BEq` is needed.

## Affected Files
- `Ledger/Core/EntityId.lean` (lines 19-20)
- `Ledger/Core/Attribute.lean` (lines 19-20)
- `Ledger/Index/Types.lean` (multiple key types)
