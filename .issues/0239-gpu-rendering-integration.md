---
id: 239
title: GPU Rendering Integration
status: closed
priority: high
created: 2026-01-07T04:06:53
updated: 2026-01-07T04:46:52
labels: []
assignee: 
project: vane
blocks: []
blocked_by: []
---

# GPU Rendering Integration

## Description
Complete the GPU-accelerated rendering pipeline using afferent's Metal backend. This is the core differentiating feature of Vane. Affects: Vane/Render/Grid.lean, Vane/App/Loop.lean

## Progress
- [2026-01-07T04:46:47] Added Batch.addAxisAlignedRect to afferent for fast axis-aligned rectangle batching. Updated Vane Grid.lean to use batched GPU rendering - all backgrounds now rendered in a single draw call.
- [2026-01-07T04:46:52] Closed: GPU rendering integration complete. Added Batch.addAxisAlignedRect to afferent and updated Vane to batch all cell backgrounds into a single GPU draw call.
