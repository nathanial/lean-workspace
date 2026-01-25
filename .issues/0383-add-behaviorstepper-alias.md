---
id: 383
title: Add Behavior.stepper alias
status: closed
priority: low
created: 2026-01-17T09:41:58
updated: 2026-01-25T02:22:48
labels: [behavior]
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Add Behavior.stepper alias

## Description
Alias for hold combinator. Common name in other FRP libraries (reactive-banana, sodium) for API familiarity.

## Progress
- [2026-01-25T02:22:48] Closed: Added Behavior.stepper alias for Behavior.hold in Core/Behavior.lean and Behavior.stepperM alias for Behavior.holdM in Host/Spider/Behavior.lean. Provides API familiarity for users coming from reactive-banana or sodium.
