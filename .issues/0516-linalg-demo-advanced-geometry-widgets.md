---
id: 516
title: Linalg Demo: Advanced Geometry Widgets
status: closed
priority: medium
created: 2026-01-30T02:28:07
updated: 2026-02-01T19:33:57
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Advanced Geometry Widgets

## Description
Create 3 advanced geometry visualization widgets:

1. **VoronoiDelaunayDual** - Point set with both Voronoi diagram and Delaunay triangulation. Shows dual relationship. Toggle each visualization. Circumcircle display. Incremental construction animation. Demonstrates Delaunay.triangulate, Voronoi.fromDelaunay, VoronoiCell, empty circumcircle property.

2. **ConvexHull2D** - Point cloud with convex hull computed and displayed. Add/remove/move points. Gift wrapping algorithm animation. Point-in-hull query. Demonstrates Polygon2D, hull construction algorithms, extreme points.

3. **TransformHierarchy** - Hierarchical tree of objects (robot arm). Child transforms relative to parents. Local vs world space gizmos. Transform interpolation. Demonstrates Transform, toMat4, parent-child composition, Transform.lerp/slerp for animation.

## Progress
- [2026-02-01T19:33:53] Implemented Voronoi/Delaunay, Convex Hull, and Transform Hierarchy demos; wired tabs and local linalg dependency. Build succeeded; lake test fails due to missing macOS frameworks/libs in environment.
- [2026-02-01T19:33:56] Closed: implemented new geometry demos (voronoi/delaunay, convex hull, transform hierarchy) and wired tabs; added local linalg dependency
