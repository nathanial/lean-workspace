---
id: 54
title: Async Event Polling
status: open
priority: medium
created: 2026-01-06T22:45:46
updated: 2026-01-06T22:45:46
labels: [feature]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Async Event Polling

## Description
Implement non-blocking async I/O for event polling using Lean's Task system, allowing applications to perform background work while waiting for input. Current synchronous polling blocks the main thread. Affects: ffi/terminus.c, Terminus/Input/Events.lean, Terminus/Backend/TerminalEffect.lean

