---
id: 422
title: Implement cascade evaluation
status: closed
priority: medium
created: 2026-01-25T02:08:20
updated: 2026-01-25T02:50:58
labels: [phase3]
assignee: 
project: smalltalk
blocks: []
blocked_by: []
---

# Implement cascade evaluation

## Description
Evaluate cascaded messages with semicolon (e.g., obj foo; bar: 1)

## Progress
- [2026-01-25T02:50:58] Closed: Cascade evaluation implemented - evaluates receiver once, sends all messages to it, returns receiver (Smalltalk-80 semantics)
