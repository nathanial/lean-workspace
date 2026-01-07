---
id: 139
title: Optimize DateTime.compare implementation
status: open
priority: low
created: 2026-01-07T00:02:15
updated: 2026-01-07T00:02:15
labels: []
assignee: 
project: chronos
blocks: []
blocked_by: []
---

# Optimize DateTime.compare implementation

## Description
DateTime.compare uses nested pattern matching on 7 fields. Convert to timestamp and compare, or use lexicographic ordering on a tuple for simpler, potentially faster code.

