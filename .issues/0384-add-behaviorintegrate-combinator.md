---
id: 384
title: Add Behavior.integrate combinator
status: closed
priority: low
created: 2026-01-17T09:41:58
updated: 2026-01-25T02:30:06
labels: [behavior]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Behavior.integrate combinator

## Description
Numerical integration over time. Niche but useful for physics simulations and continuous animations.

## Progress
- [2026-01-25T02:30:05] Closed: Closing as won't implement. Numerical integration is already achievable with existing foldDyn + sample patterns. A dedicated combinator would need opinionated choices about time sources, and the use case (physics simulations) is niche. Users can implement integration with: foldDyn (fun dt pos => pos + velocity.sample * dt) 0.0 frameEvent
