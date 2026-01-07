---
id: 258
title: Add Proper Error Handling in PTY Operations
status: open
priority: medium
created: 2026-01-07T04:08:11
updated: 2026-01-07T04:08:11
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Add Proper Error Handling in PTY Operations

## Description
PTY FFI functions can fail but errors are not always handled gracefully. Add try/catch blocks in main loop for PTY operations. Affects: Vane/App/Loop.lean

