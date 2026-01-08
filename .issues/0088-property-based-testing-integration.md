---
id: 88
title: Property-Based Testing Integration
status: closed
priority: low
created: 2026-01-06T22:57:18
updated: 2026-01-08T07:36:25
labels: [feature]
assignee: 
project: crucible
blocks: []
blocked_by: []
---

# Property-Based Testing Integration

## Description
Add hooks or utilities for integrating with property-based testing libraries like plausible. Some projects already use plausible (tincture, chroma). The collimator tests show manual property testing patterns that could be formalized. Affected files: new Crucible/Property.lean for property test helpers and assertions. Optional dependency on plausible.

## Progress
- [2026-01-08T07:36:25] Closed: Implemented lightweight property-based testing framework with Gen monad, Arbitrary/Shrinkable typeclasses, proptest syntax, and 19 property tests. Commit 090b24f.
