---
id: 564
title: Port demo tab to Canopy: textureMatrix
status: closed
priority: medium
created: 2026-02-01T04:32:38
updated: 2026-02-01T04:39:33
labels: []
assignee: 
project: afferent-demos
blocks: []
blocked_by: []
---

# Port demo tab to Canopy: textureMatrix

## Description
Replace stub in Demos/Core/Runner/CanopyApp.lean for .textureMatrix with Canopy widget; port implementation from graphics/afferent-demos/Demos/Visuals/TextureMatrix.lean.

## Progress
- [2026-02-01T04:39:28] Wired textureMatrix tab in CanopyApp using textureMatrixWidget.
- [2026-02-01T04:39:31] Ran ./build.sh in graphics/afferent-demos (warnings only).
- [2026-02-01T04:39:33] Closed: Connected textureMatrix tab to CanopyApp via textureMatrixWidget.
