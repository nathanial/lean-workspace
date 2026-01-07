---
id: 265
title: Consolidate Duplicate withFg/setFg Methods
status: open
priority: medium
created: 2026-01-07T04:08:40
updated: 2026-01-07T04:08:40
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Consolidate Duplicate withFg/setFg Methods

## Description
Cell has both withFg and setFg methods that do the same thing. Remove duplicate setFg/setBg methods, keep withFg/withBg for consistency. Affects: Vane/Core/Cell.lean

