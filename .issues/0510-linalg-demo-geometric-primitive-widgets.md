---
id: 510
title: Linalg Demo: Geometric Primitive Widgets
status: closed
priority: medium
created: 2026-01-30T02:28:06
updated: 2026-01-30T20:11:03
labels: []
assignee: 
project: afferent
blocks: []
blocked_by: []
---

# Linalg Demo: Geometric Primitive Widgets

## Description
Create 4 geometric primitive and intersection widgets:

1. **RayCastingPlayground** - Scene with sphere, AABB, plane, triangle. Draggable ray origin/direction. Shows hit points, normals, t-values. Demonstrates Ray, Intersection.raySphere, rayAABB, rayPlane, rayTriangle.

2. **PrimitiveOverlapTester** - Two movable primitives with overlap detection. Highlights intersection region, shows contact normal and penetration depth. Demonstrates Intersection.sphereSphere, aabbAABB, sphereAABB, Collision2D tests.

3. **BarycentricCoordinates** - Triangle with movable test point. Shows barycentric coords (u,v,w) as RGB color gradient. Demonstrates Triangle, Triangle.barycentric, Triangle.fromBarycentric, BarycentricCoords.isInside.

4. **FrustumCullingDemo** - Camera frustum with multiple objects. Color-coded visibility (visible, partial, culled). Demonstrates Frustum, Frustum.fromViewProjection, containsPoint, containsSphere, containsAABB.

## Progress
- [2026-01-30T20:10:56] Added four geometry demos (ray casting, overlap tester, barycentric, frustum culling) and wired into demo registry; build.sh passes.
- [2026-01-30T20:11:02] Closed: Implemented geometric primitive demos (ray casting, overlap tester, barycentric, frustum culling) and wired them into the demo registry; build passes.
