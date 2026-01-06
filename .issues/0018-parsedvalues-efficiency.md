---
id: 18
title: ParsedValues efficiency
status: open
priority: medium
created: 2026-01-06T14:48:12
updated: 2026-01-06T14:48:12
labels: []
assignee: 
project: parlance
blocks: []
blocked_by: []
---

# ParsedValues efficiency

## Description
ParsedValues uses List (String x String) with linear search and append. Use Std.HashMap or Lean.RBMap for O(log n) or O(1) lookups. Better performance for commands with many flags. Affects: Core/Types.lean (ParsedValues structure)

