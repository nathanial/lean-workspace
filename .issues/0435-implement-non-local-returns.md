---
id: 435
title: Implement non-local returns
status: closed
priority: high
created: 2026-01-25T02:08:45
updated: 2026-01-25T03:29:04
labels: [phase5]
assignee: 
project: smalltalk
blocks: []
blocked_by: []
---

# Implement non-local returns

## Description
Handle ^ return inside blocks to exit enclosing method

## Progress
- [2026-01-25T03:29:04] Closed: Implemented in commit b0bce89 - EvalError.returnValue propagates up to method boundary
