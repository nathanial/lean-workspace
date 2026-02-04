---
id: 531
title: Standardize Naming Convention for Query Functions
status: closed
priority: medium
created: 2026-01-31T00:10:16
updated: 2026-02-04T02:19:06
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Standardize Naming Convention for Query Functions

## Description
Inconsistent naming between modules: findByAttrValue vs datomsForAttrValue, entitiesWithAttr vs findEntitiesWith. Establish naming convention (verb-first vs noun-first), rename functions for consistency, add deprecation aliases. Files: Db/Database.lean, DSL/Combinators.lean, DSL/QueryBuilder.lean. Small effort.

## Progress
- [2026-02-04T02:19:06] Closed: standardized query naming, added deprecated aliases, updated docs and tests
