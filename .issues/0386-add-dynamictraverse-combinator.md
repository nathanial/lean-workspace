---
id: 386
title: Add Dynamic.traverse combinator
status: closed
priority: high
created: 2026-01-17T09:42:12
updated: 2026-02-02T04:01:20
labels: [dynamic]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Dynamic.traverse combinator

## Description
Apply (a → Dynamic b) to List a, producing Dynamic (List b). Essential for mapping over lists with reactive transformations.

## Progress
- [2026-02-02T04:01:18] Added Dynamic.traverseM wrapper over sequenceM and updated docs; lake test passes (warnings in Chronos/Reactive tests).
- [2026-02-02T04:01:20] Closed: added Dynamic.traverseM combinator and documented it
