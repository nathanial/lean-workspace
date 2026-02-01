---
id: 568
title: Port demo tab to Canopy: vectorInterpolation
status: closed
priority: medium
created: 2026-02-01T04:32:38
updated: 2026-02-01T04:47:25
labels: []
assignee: 
project: afferent-demos
blocks: []
blocked_by: []
---

# Port demo tab to Canopy: vectorInterpolation

## Description
Replace stub in Demos/Core/Runner/CanopyApp.lean for .vectorInterpolation with Canopy widget; port implementation from graphics/afferent-demos/Demos/Linalg/VectorInterpolation.lean.

## Progress
- [2026-02-01T04:47:01] Ported vectorInterpolation to CanopyApp with click/hover/mouse-up/space handling and animated t updates.
- [2026-02-01T04:47:18] Ran ./build.sh in graphics/afferent-demos (warnings only).
- [2026-02-01T04:47:25] Closed: Connected vectorInterpolation tab to CanopyApp with Canopy event wiring for drag and space toggle.
