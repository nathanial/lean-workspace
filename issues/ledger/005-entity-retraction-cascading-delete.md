# Entity Retraction (Cascading Delete)

**Priority:** Medium
**Section:** Feature Proposals
**Estimated Effort:** Medium
**Dependencies:** Schema System (for component relationships)

## Description
Implement whole-entity retraction that removes all facts about an entity, optionally cascading to component entities.

## Rationale
Currently, retractions must specify exact attribute-value pairs. There is no way to:
- Retract all facts about an entity at once
- Handle component relationships (where child entities should be retracted with parent)
- Clean up dangling references

## Affected Files
- Modify: `Ledger/Tx/Types.lean` (add `TxOp.retractEntity`)
- Modify: `Ledger/Db/Database.lean` (implement entity retraction)
- Modify: `Ledger/DSL/TxBuilder.lean` (add `retractEntity` builder)
