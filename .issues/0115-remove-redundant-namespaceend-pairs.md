---
id: 115
title: Remove Redundant namespace/end Pairs
status: open
priority: low
created: 2026-01-06T23:29:20
updated: 2026-01-06T23:29:20
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Remove Redundant namespace/end Pairs

## Description
Some small namespaces could be combined or simplified. For example, ContainerKind and ItemKind in Node.lean have very few members each. Consider combining related types into a single namespace or using dot notation directly. Effort: Small

