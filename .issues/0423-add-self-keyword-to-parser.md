---
id: 423
title: Add self keyword to parser
status: closed
priority: high
created: 2026-01-25T02:08:20
updated: 2026-01-25T02:50:59
labels: [phase3]
assignee: 
project: smalltalk
blocks: []
blocked_by: []
---

# Add self keyword to parser

## Description
Add 'self' as a reserved keyword that refers to the current receiver

## Progress
- [2026-01-25T02:50:59] Closed: Self keyword support added - ExecState.self field holds current receiver, Expr.var self handled specially in evalExpr
