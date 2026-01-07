---
id: 260
title: Extract Parser Actions to Separate File
status: open
priority: low
created: 2026-01-07T04:08:12
updated: 2026-01-07T04:08:12
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Extract Parser Actions to Separate File

## Description
Parser step functions are defined inside where clauses in Machine.lean, making them hard to test individually. Extract step functions as top-level definitions. Affects: Vane/Parser/Machine.lean

