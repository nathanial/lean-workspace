---
id: 385
title: Add Dynamic.sequence combinator
status: closed
priority: high
created: 2026-01-17T09:42:12
updated: 2026-01-25T02:46:50
labels: [dynamic]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Dynamic.sequence combinator

## Description
Convert List (Dynamic a) to Dynamic (List a). Essential for working with dynamic collections where each element is reactive.

## Progress
- [2026-01-25T02:46:50] Closed: Implemented Dynamic.sequenceM and Dynamic.sequenceArrayM in Host/Spider/Dynamic.lean. Converts List/Array of Dynamics into Dynamic of List/Array. Updates whenever any input dynamic changes.
