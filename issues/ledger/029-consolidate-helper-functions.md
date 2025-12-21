# Consolidate Helper Functions

**Priority:** Low
**Section:** Code Cleanup
**Estimated Effort:** Small
**Dependencies:** None

## Description
Some helper functions are duplicated or very similar across modules:
- `filterVisible` in `Ledger/Db/Database.lean` vs `filterVisibleAt` in `Ledger/Db/TimeTravel.lean`
- `sameFact` and `groupByFact` in `TimeTravel.lean` could be in Core

## Rationale
Move shared utilities to a common module (e.g., `Ledger/Core/Util.lean`). Reuse rather than reimplement similar logic. Document the shared utilities.

## Affected Files
- `Ledger/Db/Database.lean`
- `Ledger/Db/TimeTravel.lean`
