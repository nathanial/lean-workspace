---
id: 561
title: Port demo tab to Canopy: lineCaps
status: closed
priority: medium
created: 2026-02-01T04:32:38
updated: 2026-02-01T04:34:42
labels: []
assignee: 
project: afferent-demos
blocks: []
blocked_by: []
---

# Port demo tab to Canopy: lineCaps

## Description
Replace stub in Demos/Core/Runner/CanopyApp.lean for .lineCaps with Canopy widget; port implementation from graphics/afferent-demos/Demos/Visuals/LineCaps.lean.

## Progress
- [2026-02-01T04:33:58] Starting Canopy port for lineCaps tab; adding tab content in CanopyApp.
- [2026-02-01T04:34:17] Added lineCaps tab content in CanopyApp with lineCapsWidget and import.
- [2026-02-01T04:34:38] Ran lake test in graphics/afferent-demos; link failed (missing macOS frameworks/libs like Metal/Cocoa, libcurl).
- [2026-02-01T04:34:42] Closed: Wired lineCaps tab to CanopyApp using existing lineCapsWidget.
