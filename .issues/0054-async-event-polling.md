---
id: 54
title: Async Event Polling
status: closed
priority: medium
created: 2026-01-06T22:45:46
updated: 2026-01-07T23:34:20
labels: [feature]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Async Event Polling

## Description
Implement non-blocking async I/O for event polling using Lean's Task system, allowing applications to perform background work while waiting for input. Current synchronous polling blocks the main thread. Affects: ffi/terminus.c, Terminus/Input/Events.lean, Terminus/Backend/TerminalEffect.lean

## Progress
- [2026-01-07T23:34:20] Added blocking read path in FFI and TerminalEffect, updated Events.read to avoid busy-waiting, and added async read APIs/tests.
- [2026-01-07T23:34:20] Closed: Poll-based blocking read plus async Task APIs wired through IO/mock with tests.
