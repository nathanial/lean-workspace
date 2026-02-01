---
id: 563
title: Port demo tab to Canopy: linesPerf
status: closed
priority: medium
created: 2026-02-01T04:32:38
updated: 2026-02-01T04:39:21
labels: []
assignee: 
project: afferent-demos
blocks: []
blocked_by: []
---

# Port demo tab to Canopy: linesPerf

## Description
Replace stub in Demos/Core/Runner/CanopyApp.lean for .linesPerf with Canopy widget; port implementation from graphics/afferent-demos/Demos/Perf/Lines.lean.

## Progress
- [2026-02-01T04:39:15] Wired linesPerf tab in CanopyApp using linesPerfWidget.
- [2026-02-01T04:39:18] Ran ./build.sh in graphics/afferent-demos (warnings only).
- [2026-02-01T04:39:21] Closed: Connected linesPerf tab to CanopyApp via linesPerfWidget.
