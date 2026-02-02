---
id: 711
title: Migrate ArcLengthParameterization to MathView2D
status: closed
priority: medium
created: 2026-02-02T20:20:23
updated: 2026-02-02T20:29:34
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Migrate ArcLengthParameterization to MathView2D

## Description
Update afferent-demos Demos/Linalg/ArcLengthParameterization.lean to use Afferent.Widget.MathView2D for grid/axes/labels and world-to-screen transforms.

## Progress
- [2026-02-02T20:29:29] Migrated ArcLengthParameterization to MathView2D and updated input hit-testing to use MathView2D view transforms.
- [2026-02-02T20:29:34] Closed: ArcLengthParameterization now uses MathView2D for grid/axes/labels and view transforms; input handling updated accordingly.
