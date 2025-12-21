# Add Docstrings to Inductive Constructors

**Priority:** Medium
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Inductive types like `Value`, `TxOp`, `PullPattern`, `Clause` have constructor documentation in some cases but not all.

## Rationale
Add docstrings to all constructors explaining their purpose. Include usage examples where appropriate.

## Affected Files
- `Ledger/Core/Value.lean`
- `Ledger/Tx/Types.lean`
- `Ledger/Pull/Pattern.lean`
- `Ledger/Query/AST.lean`
