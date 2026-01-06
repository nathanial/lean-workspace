---
id: 80
title: Layered Rendering
status: open
priority: medium
created: 2026-01-06T22:46:46
updated: 2026-01-06T22:46:46
labels: [architecture]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Layered Rendering

## Description
Popups and overlays are rendered inline with other widgets, which can cause Z-ordering issues. Implement a layered rendering system with: background layer (normal widgets), overlay layer (popups, dropdowns), top layer (tooltips, notifications).

