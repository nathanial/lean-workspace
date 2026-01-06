---
id: 106
title: Type-Safe Node IDs
status: open
priority: medium
created: 2026-01-06T23:28:56
updated: 2026-01-06T23:28:56
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Type-Safe Node IDs

## Description
Node IDs are raw Nat values that can be confused with other numeric values. Create an opaque NodeId type to prevent accidental misuse of numeric values as node identifiers. Affected files: Node.lean, Result.lean, Algorithm.lean. Effort: Small

