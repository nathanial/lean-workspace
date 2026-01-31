---
id: 529
title: Consolidate Key Types with Datom Comparison Functions
status: open
priority: medium
created: 2026-01-31T00:10:11
updated: 2026-01-31T00:10:11
labels: []
assignee: 
project: ledger
blocks: []
blocked_by: []
---

# Consolidate Key Types with Datom Comparison Functions

## Description
Four separate key types (EAVTKey, AEVTKey, AVETKey, VAETKey) in Ledger/Index/Types.lean duplicate ordering logic also in Ledger/Core/Datom.lean. Consider newtype wrappers over Datom with different Ord instances, metaprogramming, or consolidate comparison logic. Medium effort.

