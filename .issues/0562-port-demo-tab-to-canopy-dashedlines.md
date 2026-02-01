---
id: 562
title: Port demo tab to Canopy: dashedLines
status: closed
priority: medium
created: 2026-02-01T04:32:38
updated: 2026-02-01T04:36:20
labels: []
assignee: 
project: afferent-demos
blocks: []
blocked_by: []
---

# Port demo tab to Canopy: dashedLines

## Description
Replace stub in Demos/Core/Runner/CanopyApp.lean for .dashedLines with Canopy widget; port implementation from graphics/afferent-demos/Demos/Visuals/DashedLines.lean.

## Progress
- [2026-02-01T04:35:51] Starting Canopy port for dashedLines tab; wiring dashedLinesWidget into CanopyApp.
- [2026-02-01T04:36:16] Added dashedLines tab content in CanopyApp with dashedLinesWidget and import; ran ./build.sh (warnings only).
- [2026-02-01T04:36:20] Closed: Wired dashedLines tab to CanopyApp using dashedLinesWidget.
