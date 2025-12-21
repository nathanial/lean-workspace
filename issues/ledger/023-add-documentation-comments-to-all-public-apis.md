# Add Documentation Comments to All Public APIs

**Priority:** High
**Section:** Code Cleanup
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Many public functions lack documentation comments (docstrings). While some have brief comments, a consistent documentation standard would improve usability.

## Rationale
Add docstrings to all public `def` and `structure` declarations. Document parameters, return values, and usage examples. Use consistent formatting.

## Affected Files
- `Ledger/Query/Executor.lean`
- `Ledger/Pull/Executor.lean`
- `Ledger/DSL/*.lean`
