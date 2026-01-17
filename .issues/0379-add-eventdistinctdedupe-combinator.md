---
id: 379
title: Add Event.distinct/dedupe combinator
status: open
priority: high
created: 2026-01-17T09:41:45
updated: 2026-01-17T09:41:45
labels: [event]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Event.distinct/dedupe combinator

## Description
Skip consecutive duplicate values (requires BEq). Common need to avoid redundant downstream updates when the value hasn't actually changed.

