---
id: 247
title: Mouse Input Forwarding
status: open
priority: medium
created: 2026-01-07T04:07:19
updated: 2026-01-07T04:07:19
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Mouse Input Forwarding

## Description
Forward mouse events to the PTY when mouse reporting modes are enabled. Mouse encoding is fully implemented in KeyEncoder.lean (MouseEncoder) but not connected. Affects: Vane/App/Loop.lean, Vane/Terminal/Modes.lean

