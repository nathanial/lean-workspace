---
id: 522
title: Entity Retraction (Cascading Delete)
status: open
priority: medium
created: 2026-01-31T00:09:49
updated: 2026-01-31T00:09:49
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Entity Retraction (Cascading Delete)

## Description
Implement whole-entity retraction that removes all facts about an entity, optionally cascading to component entities. Currently retractions must specify exact attribute-value pairs. Modify: Tx/Types.lean (add TxOp.retractEntity), Db/Database.lean, DSL/TxBuilder.lean. Medium effort. Depends on Schema System.

