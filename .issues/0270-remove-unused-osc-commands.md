---
id: 270
title: Remove Unused OSC Commands
status: open
priority: low
created: 2026-01-07T04:08:51
updated: 2026-01-07T04:08:51
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Remove Unused OSC Commands

## Description
Several OSC commands are parsed but do nothing (setColor, resetColor, notify, setXProperty). Either implement these features or add TODO comments explaining planned functionality. Affects: Vane/Terminal/Executor.lean

