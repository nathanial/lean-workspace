---
id: 72
title: Duplicated innerArea Pattern
status: closed
priority: medium
created: 2026-01-06T22:46:33
updated: 2026-01-07T00:56:10
labels: [cleanup]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Duplicated innerArea Pattern

## Description
Every widget has the same boilerplate for handling optional blocks and computing inner areas. Extract common pattern into a helper function, consider a Widget wrapper that handles block rendering. Location: All widget files in Terminus/Widgets/

## Progress
- [2026-01-07T00:56:10] Closed: Added renderBlockAndGetInner helper in Block.lean. Updated 22 widget instances to use the new helper, eliminating ~200 lines of duplicated boilerplate code.
