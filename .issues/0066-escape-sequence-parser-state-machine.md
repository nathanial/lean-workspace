---
id: 66
title: Escape Sequence Parser State Machine
status: open
priority: medium
created: 2026-01-06T22:46:11
updated: 2026-01-06T22:46:11
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Escape Sequence Parser State Machine

## Description
Escape sequence parsing in Terminus/Input/Events.lean uses nested pattern matching which is hard to extend. Implement a proper state machine parser that can handle arbitrary escape sequences, including CSI parameters. More robust input handling, easier to add new key sequences.

