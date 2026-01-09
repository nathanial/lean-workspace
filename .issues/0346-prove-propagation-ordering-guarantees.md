---
id: 346
title: Prove propagation ordering guarantees
status: closed
priority: low
created: 2026-01-09T08:56:16
updated: 2026-01-09T10:03:13
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Prove propagation ordering guarantees

## Description
Prove that height-based propagation ordering prevents glitches: (1) events at lower heights fire before higher heights within a frame, (2) derived nodes see consistent state from all their sources. This is the key correctness property for the FRP runtime.

## Progress
- [2026-01-09T09:51:22] Closed: Implemented formal specification of propagation ordering guarantees with axioms and proofs for glitch-freedom. Proves height_ordered_implies_glitch_free, spider_is_glitch_free, dependencies_fire_first, and diamond_consistency theorems.
- [2026-01-09T10:03:13] Closed: Added PropagationLaws.lean with height-based ordering axioms and glitch-freedom theorems
