---
id: 567
title: Port demo tab to Canopy: chatDemo
status: closed
priority: medium
created: 2026-02-01T04:32:38
updated: 2026-02-01T04:40:08
labels: []
assignee: 
project: afferent-demos
blocks: []
blocked_by: []
---

# Port demo tab to Canopy: chatDemo

## Description
Replace stub in Demos/Core/Runner/CanopyApp.lean for .chatDemo with Canopy widget; port implementation from graphics/afferent-demos/Demos/Chat/App.lean.

## Progress
- [2026-02-01T04:40:03] Wired chatDemo tab in CanopyApp using ChatDemo.createApp render.
- [2026-02-01T04:40:05] Ran ./build.sh in graphics/afferent-demos (warnings only).
- [2026-02-01T04:40:08] Closed: Connected chatDemo tab to CanopyApp via ChatDemo.createApp render.
