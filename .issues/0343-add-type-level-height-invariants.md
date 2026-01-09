---
id: 343
title: Add type-level height invariants
status: closed
priority: low
created: 2026-01-09T08:56:16
updated: 2026-01-09T09:47:19
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add type-level height invariants

## Description
Encode height ordering invariants in types so derived events are guaranteed to have greater height than sources. Example: structure DerivedEvent (source : Event t b) where event : Event t a; height_gt : event.height > source.height. This would make glitch-free propagation provable by construction.

## Progress
- [2026-01-09T09:47:19] Closed: Won't fix - over-engineering. The height invariant is already maintained internally by combinators. Type-level encoding would add complexity without practical benefit for a runtime FRP system.
