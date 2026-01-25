---
id: 389
title: Add Dynamic.scanMaybe combinator
status: closed
priority: medium
created: 2026-01-17T09:42:13
updated: 2026-01-25T02:40:07
labels: [dynamic]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Dynamic.scanMaybe combinator

## Description
Like scan but can filter updates. Returns Option to indicate whether to emit the accumulated value.

## Progress
- [2026-01-25T02:40:07] Closed: Duplicate of #388 (foldDynMaybe). Both describe conditional folding over events - implementing one covers both use cases.
