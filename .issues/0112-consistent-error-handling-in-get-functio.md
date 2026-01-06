---
id: 112
title: Consistent Error Handling in get! Functions
status: open
priority: medium
created: 2026-01-06T23:29:20
updated: 2026-01-06T23:29:20
labels: []
assignee: 
project: trellis
blocks: []
blocked_by: []
---

# Consistent Error Handling in get! Functions

## Description
LayoutResult.get! uses panic! which is not recoverable. Consider returning Option or using an error monad. Either remove the get! function, rename to getOrPanic, or convert to a proper error type. Affected: Result.lean. Effort: Small

