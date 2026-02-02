---
id: 712
title: Migrate BSplineCurveDemo to MathView2D
status: closed
priority: medium
created: 2026-02-02T20:20:23
updated: 2026-02-02T20:43:08
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Migrate BSplineCurveDemo to MathView2D

## Description
Update afferent-demos Demos/Linalg/BSplineCurveDemo.lean to use Afferent.Widget.MathView2D for grid/axes/labels and world-to-screen transforms.

## Progress
- [2026-02-02T20:43:04] Migrated BSplineCurveDemo to MathView2D and updated input hit-testing to use MathView2D view transforms.
- [2026-02-02T20:43:08] Closed: BSplineCurveDemo now uses MathView2D for grid/axes/labels and view transforms; input handling updated accordingly.
