---
id: 213
title: Fix deprecated API usage
status: closed
priority: high
created: 2026-01-07T03:50:06
updated: 2026-01-07T04:21:16
labels: [cleanup]
assignee: 
project: sift
blocks: []
blocked_by: []
---

# Fix deprecated API usage

## Description
Replace deprecated Lean 4 APIs:
- String.get → String.Pos.Raw.get
- String.mk → String.ofList

Locations:
- Sift/Core.lean: lines 46, 52
- Sift/Primitives.lean: lines 44, 55
- Sift/Text.lean: lines 17, 22, 113

Effort: Small

## Progress
- [2026-01-07T04:21:16] Closed: Replaced String.get with String.Pos.Raw.get, String.extract with String.Pos.Raw.extract, String.mk with String.ofList
