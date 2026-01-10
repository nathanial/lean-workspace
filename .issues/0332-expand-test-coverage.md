---
id: 332
title: Expand Test Coverage
status: closed
priority: medium
created: 2026-01-09T08:12:03
updated: 2026-01-10T14:05:04
labels: []
assignee: 
project: reactive
blocks: []
blocked_by: []
---

# Expand Test Coverage

## Description
Tests cover basic functionality but lack coverage for: edge cases (empty events, zero subscribers), combinator interactions, error conditions, and memory leak scenarios. Add tests for all combinators in Event.lean and Behavior.lean, stress tests for subscription management, and tests for complex network topologies.

## Progress
- [2026-01-10T14:04:59] Added delayFrame tests, scope disposal stress coverage, and mergeList+delayFrame topology coverage; verified reactive_tests pass.
- [2026-01-10T14:05:04] Closed: added delayFrame coverage, scope disposal stress test, and mergeList+delayFrame topology test; tests green
