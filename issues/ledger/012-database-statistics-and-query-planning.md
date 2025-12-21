# Database Statistics and Query Planning

**Priority:** Low
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Maintain statistics about data distribution and use them for query optimization.

## Rationale
The current query executor orders patterns by selectivity using a simple heuristic (bound term count). Statistics would enable:
- Cardinality estimation
- Cost-based query planning
- Adaptive query optimization

## Affected Files
- New file: `Ledger/Stats/Statistics.lean`
- Modify: `Ledger/Query/IndexSelect.lean` (use statistics)
- Modify: `Ledger/Db/Database.lean` (maintain statistics)
