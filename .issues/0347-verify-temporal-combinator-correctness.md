---
id: 347
title: Verify temporal combinator correctness
status: closed
priority: low
created: 2026-01-09T08:56:17
updated: 2026-01-09T10:02:45
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Verify temporal combinator correctness

## Description
Prove correctness of temporal combinators (delayFrame, debounce, throttle): (1) delayFrame delays exactly one frame, (2) debounce only fires after quiet period, (3) throttle respects rate limit. Requires a formal time model (discrete steps or duration-based).

## Progress
- [2026-01-09T10:02:45] Closed: Added TemporalLaws.lean with specifications for delayFrame, debounce, and throttle temporal combinators
