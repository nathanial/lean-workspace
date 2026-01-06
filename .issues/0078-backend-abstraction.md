---
id: 78
title: Backend Abstraction
status: open
priority: high
created: 2026-01-06T22:46:45
updated: 2026-01-06T22:46:45
labels: [architecture]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Backend Abstraction

## Description
Current backend is tightly coupled to Unix termios. Define a Backend typeclass with operations for: raw mode management, terminal size queries, input reading, output writing. Would enable Windows support, test backends, and alternative rendering targets. Affects: Terminus/Backend/Terminal.lean, TerminalIO.lean, TerminalMock.lean

