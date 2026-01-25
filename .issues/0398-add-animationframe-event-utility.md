---
id: 398
title: Add animationFrame event utility
status: closed
priority: medium
created: 2026-01-17T09:42:42
updated: 2026-01-25T02:59:41
labels: [temporal]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add animationFrame event utility

## Description
RequestAnimationFrame-style event. Fire synchronized with display refresh for smooth animations in GUI applications.

## Progress
- [2026-01-25T02:59:41] Closed: Already implemented in afferent. The reactive library is host-agnostic; animation frame events require platform-specific display sync (CVDisplayLink on macOS, etc). Afferent provides useAnimationFrame hook and fireAnimationFrame in its main loop for GUI applications. See Afferent/Canopy/Reactive/Inputs.lean and Component.lean.
