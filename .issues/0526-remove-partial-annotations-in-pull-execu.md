---
id: 526
title: Remove Partial Annotations in Pull Executor
status: open
priority: medium
created: 2026-01-31T00:10:03
updated: 2026-01-31T00:10:03
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Remove Partial Annotations in Pull Executor

## Description
pullNestedEntity and pullPatternRec functions in Ledger/Pull/Executor.lean are marked as partial. Use fuel-based recursion with a Nat counter or restructure with decreasing_by for well-founded recursion on visited set size. Removes partial annotation, enables formal verification. Medium effort.

