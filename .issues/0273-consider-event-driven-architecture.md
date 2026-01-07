---
id: 273
title: Consider Event-Driven Architecture
status: open
priority: low
created: 2026-01-07T04:09:07
updated: 2026-01-07T04:09:07
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Consider Event-Driven Architecture

## Description
Main loop polls PTY, keyboard, and window events separately. Use event queue pattern for unified event handling. Cleaner architecture, easier testing, potential async support. Affects: Vane/App/Loop.lean

