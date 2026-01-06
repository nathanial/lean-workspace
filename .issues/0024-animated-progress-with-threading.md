---
id: 24
title: Animated progress with threading
status: open
priority: low
created: 2026-01-06T14:48:36
updated: 2026-01-06T14:50:38
labels: []
assignee: 
project: parlance
blocks: [26]
blocked_by: []
---

# Animated progress with threading

## Description
Implement proper animated spinners using background threads. Current withAnimatedSpinner is a stub. Use Lean 4 Task/IO.asTask for concurrent updates. Affects: Output/Spinner.lean

