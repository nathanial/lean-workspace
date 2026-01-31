---
id: 531
title: Standardize Naming Convention for Query Functions
status: open
priority: medium
created: 2026-01-31T00:10:16
updated: 2026-01-31T00:10:16
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Standardize Naming Convention for Query Functions

## Description
Inconsistent naming between modules: findByAttrValue vs datomsForAttrValue, entitiesWithAttr vs findEntitiesWith. Establish naming convention (verb-first vs noun-first), rename functions for consistency, add deprecation aliases. Files: Db/Database.lean, DSL/Combinators.lean, DSL/QueryBuilder.lean. Small effort.

