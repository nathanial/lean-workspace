---
id: 513
title: Linalg Demo: Procedural Noise Widgets
status: closed
priority: medium
created: 2026-01-30T02:28:06
updated: 2026-01-31T19:19:01
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Procedural Noise Widgets

## Description
Create 4 procedural noise visualization widgets:

1. **NoiseExplorer2D** - 2D grid showing noise as grayscale/heightmap. Dropdown for noise type: Perlin, Simplex, Value, Worley. Scale/offset sliders. FBM parameters (octaves, lacunarity, persistence). Demonstrates Noise.perlin2D, simplex2D, value2D, worley2D, fbm2D.

2. **FBMTerrainGenerator** - 3D terrain mesh from FBM noise. All FBM parameter sliders. Redistribution power curve. Terrace levels. Wireframe/normal/texture toggles. Demonstrates Noise.fbm3D, FractalConfig, redistribute, terrace.

3. **DomainWarpingDemo** - Shows organic flowing patterns via domain warping. Before/after comparison. Warp vector visualization. Animated evolving warp. Demonstrates Noise.warp2D, warp2DAdvanced, warping strength parameters.

4. **WorleyCellularNoise** - Cellular noise with visible feature points. Dropdown for F1, F2, F2-F1, F3-F1. Jitter slider. Cell edge detection. Demonstrates Noise.worley2D, WorleyResult, worley2DF1, worley2DEdge, Voronoi connection.

## Progress
- [2026-01-31T19:19:01] Closed: All four procedural noise widgets implemented: NoiseExplorer2D, FBMTerrainGenerator, DomainWarpingDemo, WorleyCellularNoise. Registered in DemoRegistry and building successfully.
