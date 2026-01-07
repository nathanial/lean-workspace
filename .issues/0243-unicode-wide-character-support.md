---
id: 243
title: Unicode Wide Character Support
status: open
priority: medium
created: 2026-01-07T04:07:17
updated: 2026-01-07T04:07:17
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# Unicode Wide Character Support

## Description
Proper handling of Unicode combining characters and East Asian wide characters (double-width). Current implementation treats all characters as single-width. Affects: Vane/Core/Cell.lean, Vane/Core/Buffer.lean, Vane/Terminal/State.lean, Vane/Render/Grid.lean

