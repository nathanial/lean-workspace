---
id: 69
title: Float.sin/cos Performance
status: open
priority: low
created: 2026-01-06T22:46:11
updated: 2026-01-06T22:46:11
labels: [improvement]
assignee: 
project: terminus
blocks: []
blocked_by: []
---

# Float.sin/cos Performance

## Description
Several widgets (charts, animations) use Float.sin/cos which may be slower than lookup tables for animation use cases. Implement fast approximate trig functions or lookup tables for animation-quality rendering. Better performance for animated UIs. Affects: examples/KitchenSink.lean, chart widgets

