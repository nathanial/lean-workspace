---
id: 514
title: Linalg Demo: Spatial Data Structure Widgets
status: open
priority: medium
created: 2026-01-30T02:28:07
updated: 2026-01-30T02:28:07
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Spatial Data Structure Widgets

## Description
Create 4 spatial data structure visualization widgets:

1. **QuadtreeVisualizer** - 2D view with points and quadtree overlay. Click to add points. Rectangle/circle range queries with highlighted results. K-nearest neighbor on hover. Demonstrates Quadtree, build, insert, queryRect, queryCircle, kNearest, TreeConfig.

2. **OctreeViewer3D** - 3D scene with objects and octree structure. Add/remove 3D objects. Query box visualization. Level-based coloring. Demonstrates Octree, build, queryAABB, OctreeNode, OctantIndex.

3. **BVHRayTracer** - Triangle scene with BVH acceleration structure. Ray traversal visualization showing tested nodes. Stats comparing BVH vs brute force. Demonstrates BVH, build (SAH), rayCast, rayAny, BVHConfig.

4. **KDTreeNearestNeighbor** - Point cloud with KD-tree splitting planes. Click for nearest neighbor with search path. Radius search circle. K-NN query. Demonstrates KDTree, build, queryNearest, queryRadius, queryKNearest, backtracking visualization.

