# Range Queries on Indexes

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** None

## Description
Implement true range queries on RBMap indexes instead of filtering.

## Rationale
Currently, index queries like `datomsForEntity` iterate the entire index and filter (`filterMap`). The RBMap structure supports efficient range queries but they are not used.

## Affected Files
- Modify: `Ledger/Index/EAVT.lean`
- Modify: `Ledger/Index/AEVT.lean`
- Modify: `Ledger/Index/AVET.lean`
- Modify: `Ledger/Index/VAET.lean`
