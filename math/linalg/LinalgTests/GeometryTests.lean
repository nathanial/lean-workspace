/-
  Tests for geometry primitives and intersection tests.
-/

import Linalg
import Crucible

namespace LinalgTests.GeometryTests

open Crucible
open Linalg

private def meshArea (mesh : Mesh) : Float := Id.run do
  let mut area := 0.0
  for i in [:mesh.triangleCount] do
    match Mesh.triangle? mesh i with
    | none => ()
    | some tri => area := area + tri.area
  return area

private def appendBox (verts : Array Vec3) (inds : Array Nat)
    (center extents : Vec3) : Array Vec3 × Array Nat := Id.run do
  let min := center - extents
  let max := center + extents
  let base := verts.size
  let newVerts : Array Vec3 := #[
    Vec3.mk min.x min.y min.z,
    Vec3.mk max.x min.y min.z,
    Vec3.mk max.x max.y min.z,
    Vec3.mk min.x max.y min.z,
    Vec3.mk min.x min.y max.z,
    Vec3.mk max.x min.y max.z,
    Vec3.mk max.x max.y max.z,
    Vec3.mk min.x max.y max.z
  ]
  let boxIndices : Array Nat := #[
    0, 1, 2,  0, 2, 3,
    4, 6, 5,  4, 7, 6,
    1, 5, 6,  1, 6, 2,
    0, 3, 7,  0, 7, 4,
    3, 2, 6,  3, 6, 7,
    0, 4, 5,  0, 5, 1
  ]
  let mut outVerts := verts.append newVerts
  let mut outInds := inds
  for idx in boxIndices do
    outInds := outInds.push (base + idx)
  return (outVerts, outInds)

private def bridgeMesh : Mesh := Id.run do
  let mut verts : Array Vec3 := #[]
  let mut inds : Array Nat := #[]
  let (v0, i0) := appendBox verts inds (Vec3.mk (-1.3) 0.5 0.0) (Vec3.mk 0.4 0.9 0.4)
  verts := v0
  inds := i0
  let (v1, i1) := appendBox verts inds (Vec3.mk 1.3 0.5 0.0) (Vec3.mk 0.4 0.9 0.4)
  verts := v1
  inds := i1
  let (v2, i2) := appendBox verts inds (Vec3.mk 0.0 1.35 0.0) (Vec3.mk 1.6 0.22 0.4)
  verts := v2
  inds := i2
  let (v3, i3) := appendBox verts inds (Vec3.mk 0.0 0.2 0.9) (Vec3.mk 0.65 0.25 0.35)
  verts := v3
  inds := i3
  let (v4, i4) := appendBox verts inds (Vec3.mk 0.0 0.2 (-0.9)) (Vec3.mk 0.65 0.25 0.35)
  verts := v4
  inds := i4
  return Mesh.fromVerticesIndices verts inds

private def crossingQuadMesh : Mesh :=
  let vertices := #[
    Vec3.mk (-1.0) 0.0 (-1.0),
    Vec3.mk 1.0 0.0 (-1.0),
    Vec3.mk 1.0 0.0 1.0,
    Vec3.mk (-1.0) 0.0 1.0
  ]
  let indices := #[0, 1, 2, 0, 2, 3]
  { vertices, indices }

private def tinyExtentMesh : Mesh :=
  let vertices := #[
    Vec3.mk 0.0 0.0 0.0,
    Vec3.mk 0.01 0.0 0.0,
    Vec3.mk 0.0 0.01 0.0,
    Vec3.mk 0.02 0.0 0.0,
    Vec3.mk 0.03 0.0 0.0,
    Vec3.mk 0.02 0.01 0.0
  ]
  let indices := #[0, 1, 2, 3, 4, 5]
  { vertices, indices }

private def splitPlaneStressMesh : Mesh :=
  let vertices := #[
    Vec3.mk (-1.0) 0.0 (-1.0),      -- crosses plane, on-plane apex
    Vec3.mk 0.0 0.7 0.0,
    Vec3.mk 1.0 0.0 (-1.0),
    Vec3.mk (-1.0) 0.0 1.0,         -- near-plane left
    Vec3.mk (-0.000001) 0.001 0.2,
    Vec3.mk (-0.000001) 0.0 1.0,
    Vec3.mk 0.000001 0.0 1.0,       -- near-plane right
    Vec3.mk 0.000001 0.001 0.2,
    Vec3.mk 1.0 0.0 1.0
  ]
  let indices := #[
    0, 1, 2,
    3, 4, 5,
    6, 7, 8
  ]
  { vertices, indices }

private def sampleTriangleInterior (tri : Triangle) : Array Vec3 :=
  #[
    tri.v0 * 0.211 + tri.v1 * 0.337 + tri.v2 * 0.452,
    tri.v0 * 0.419 + tri.v1 * 0.193 + tri.v2 * 0.388,
    tri.v0 * 0.287 + tri.v1 * 0.266 + tri.v2 * 0.447
  ]

private def triangleContainsPoint3D (tri : Triangle) (p : Vec3) (eps : Float := 1e-5) : Bool :=
  let n := tri.normal
  if n.lengthSquared <= 1e-12 then
    false
  else
    let planeDist := Float.abs' (n.normalize.dot (p - tri.v0))
    let bc := tri.barycentric p
    planeDist <= eps &&
      bc.u >= -eps && bc.v >= -eps && bc.w >= -eps &&
      bc.u <= 1.0 + eps && bc.v <= 1.0 + eps && bc.w <= 1.0 + eps

private def meshContainsPoint3D (mesh : Mesh) (p : Vec3) (eps : Float := 1e-5) : Bool := Id.run do
  for i in [:mesh.triangleCount] do
    match Mesh.triangle? mesh i with
    | none => ()
    | some tri =>
      if triangleContainsPoint3D tri p eps then
        return true
  return false

private def surfaceSamples (mesh : Mesh) : Array Vec3 := Id.run do
  let mut points : Array Vec3 := #[]
  for i in [:mesh.triangleCount] do
    match Mesh.triangle? mesh i with
    | none => ()
    | some tri =>
      if tri.area > 1e-8 then
        points := points ++ sampleTriangleInterior tri
  return points

private def coveringPieceCount (pieces : Array ExactConvexPiece) (p : Vec3) (eps : Float := 1e-5) : Nat :=
  pieces.foldl (fun acc piece => if meshContainsPoint3D piece.mesh p eps then acc + 1 else acc) 0

private def hullCentroid (hull : ConvexHull3D) : Vec3 :=
  if hull.points.isEmpty then
    Vec3.zero
  else
    hull.points.foldl (fun acc p => acc + p) Vec3.zero * (1.0 / hull.points.size.toFloat)

private def hullPlanes (hull : ConvexHull3D) : Array (Vec3 × Float) := Id.run do
  if hull.faces.isEmpty || hull.points.isEmpty then
    return #[]
  let center := hullCentroid hull
  let mut planes : Array (Vec3 × Float) := #[]
  for (a, b, c) in hull.faces do
    let p0 := hull.points.getD a Vec3.zero
    let p1 := hull.points.getD b Vec3.zero
    let p2 := hull.points.getD c Vec3.zero
    let mut n := (p1 - p0).cross (p2 - p0)
    if n.lengthSquared <= 1e-10 then
      continue
    n := n.normalize
    if n.dot (center - p0) > 0.0 then
      n := -n
    planes := planes.push (n, n.dot p0)
  return planes

private def hullContainsPointTol (hull : ConvexHull3D) (p : Vec3) (tol : Float := 1e-4) : Bool := Id.run do
  let planes := hullPlanes hull
  if planes.isEmpty then
    return true
  let mut maxDist := (-1.0e9)
  for (n, d) in planes do
    let s := n.dot p - d
    if s > maxDist then
      maxDist := s
  return maxDist <= tol

private def coveringProxyPieceCount (pieces : Array ConvexPiece) (p : Vec3) (tol : Float := 1e-4) : Nat :=
  pieces.foldl (fun acc piece => if hullContainsPointTol piece.hull p tol then acc + 1 else acc) 0

testSuite "Ray"

test "ray pointAt works correctly" := do
  let ray := Ray.mk' Vec3.zero Vec3.unitZ
  let p := ray.pointAt 5.0
  ensure (floatNear p.z 5.0 0.0001) "z should be 5"

testSuite "AABB"

test "AABB center is correct" := do
  let aabb := AABB.fromMinMax (Vec3.mk 0.0 0.0 0.0) (Vec3.mk 10.0 10.0 10.0)
  let c := aabb.center
  ensure (floatNear c.x 5.0 0.0001) "center x should be 5"
  ensure (floatNear c.y 5.0 0.0001) "center y should be 5"
  ensure (floatNear c.z 5.0 0.0001) "center z should be 5"

test "AABB contains center point" := do
  let aabb := AABB.fromMinMax Vec3.zero (Vec3.mk 10.0 10.0 10.0)
  ensure (aabb.containsPoint (Vec3.mk 5.0 5.0 5.0)) "should contain center"

test "AABB does not contain point outside" := do
  let aabb := AABB.fromMinMax Vec3.zero (Vec3.mk 10.0 10.0 10.0)
  ensure (!(aabb.containsPoint (Vec3.mk 15.0 5.0 5.0))) "should not contain outside point"

testSuite "Sphere"

test "sphere contains its center" := do
  let s := Sphere.mk' (Vec3.mk 5.0 5.0 5.0) 3.0
  ensure (s.containsPoint s.center) "should contain center"

test "sphere does not contain distant point" := do
  let s := Sphere.mk' Vec3.zero 1.0
  ensure (!(s.containsPoint (Vec3.mk 10.0 0.0 0.0))) "should not contain distant point"

testSuite "Plane"

test "point on XY plane has zero distance" := do
  let p := Plane.xy
  let point := Vec3.mk 5.0 5.0 0.0
  ensure (floatNear (p.distanceToPoint point) 0.0 0.0001) "distance should be 0"

test "point above XY plane has positive signed distance" := do
  let p := Plane.xy
  let point := Vec3.mk 0.0 0.0 5.0
  ensure (floatNear (p.signedDistance point) 5.0 0.0001) "signed distance should be 5"

testSuite "Intersection"

test "ray hits sphere from outside" := do
  let ray := Ray.mk' (Vec3.mk 0.0 0.0 (-10.0)) Vec3.unitZ
  let sphere := Sphere.mk' Vec3.zero 1.0
  match Intersection.raySphere ray sphere with
  | some hit => ensure (floatNear hit.t 9.0 0.0001) "t should be 9"
  | none => ensure false "expected ray to hit sphere"

test "ray misses sphere" := do
  let ray := Ray.mk' (Vec3.mk 10.0 0.0 (-10.0)) Vec3.unitZ
  let sphere := Sphere.mk' Vec3.zero 1.0
  match Intersection.raySphere ray sphere with
  | some _ => ensure false "expected ray to miss sphere"
  | none => pure ()

test "ray hits AABB" := do
  let ray := Ray.mk' (Vec3.mk 0.0 0.0 (-10.0)) Vec3.unitZ
  let aabb := AABB.fromMinMax (Vec3.mk (-1.0) (-1.0) (-1.0)) (Vec3.mk 1.0 1.0 1.0)
  match Intersection.rayAABB ray aabb with
  | some (tMin, _) => ensure (floatNear tMin 9.0 0.0001) "tMin should be 9"
  | none => ensure false "expected ray to hit AABB"

test "ray hits plane" := do
  let ray := Ray.mk' (Vec3.mk 0.0 0.0 (-5.0)) Vec3.unitZ
  let plane := Plane.xy
  match Intersection.rayPlane ray plane with
  | some hit => ensure (floatNear hit.t 5.0 0.0001) "t should be 5"
  | none => ensure false "expected ray to hit plane"

test "sphere-sphere intersection" := do
  let a := Sphere.mk' Vec3.zero 2.0
  let b := Sphere.mk' (Vec3.mk 3.0 0.0 0.0) 2.0
  ensure (Intersection.sphereSphere a b) "spheres should intersect"

test "sphere-sphere no intersection" := do
  let a := Sphere.mk' Vec3.zero 1.0
  let b := Sphere.mk' (Vec3.mk 10.0 0.0 0.0) 1.0
  ensure (!(Intersection.sphereSphere a b)) "spheres should not intersect"

test "AABB-AABB intersection" := do
  let a := AABB.fromMinMax Vec3.zero (Vec3.mk 5.0 5.0 5.0)
  let b := AABB.fromMinMax (Vec3.mk 3.0 3.0 3.0) (Vec3.mk 8.0 8.0 8.0)
  ensure (Intersection.aabbAABB a b) "AABBs should intersect"

test "AABB-AABB no intersection" := do
  let a := AABB.fromMinMax Vec3.zero (Vec3.mk 1.0 1.0 1.0)
  let b := AABB.fromMinMax (Vec3.mk 5.0 5.0 5.0) (Vec3.mk 6.0 6.0 6.0)
  ensure (!(Intersection.aabbAABB a b)) "AABBs should not intersect"

testSuite "Mesh"

test "mesh rayCast hits triangle" := do
  let vertices := #[
    Vec3.mk 0.0 0.0 0.0,
    Vec3.mk 1.0 0.0 0.0,
    Vec3.mk 0.0 1.0 0.0
  ]
  let indices := #[0, 1, 2]
  let mesh : Mesh := { vertices, indices }
  let ray := Ray.mk' (Vec3.mk 0.25 0.25 (-1.0)) Vec3.unitZ
  match Mesh.rayCast mesh ray with
  | some hit => ensure (hit.t > 0.0) "expected hit with positive t"
  | none => ensure false "expected ray to hit mesh"

test "mesh BVH rayCast hits triangle" := do
  let vertices := #[
    Vec3.mk 0.0 0.0 0.0,
    Vec3.mk 1.0 0.0 0.0,
    Vec3.mk 0.0 1.0 0.0
  ]
  let indices := #[0, 1, 2]
  let mesh : Mesh := { vertices, indices }
  let ray := Ray.mk' (Vec3.mk 0.25 0.25 (-1.0)) Vec3.unitZ
  match Linalg.Spatial.MeshBVH.build mesh with
  | none => ensure false "expected BVH to build"
  | some bvh =>
    match Linalg.Spatial.MeshBVH.rayCast mesh bvh ray with
    | some hit => ensure (hit.t > 0.0) "expected BVH hit with positive t"
    | none => ensure false "expected BVH ray to hit mesh"

testSuite "ConvexHull3D"

test "quickhull builds tetrahedron" := do
  let points := #[
    Vec3.mk 0.0 0.0 0.0,
    Vec3.mk 1.0 0.0 0.0,
    Vec3.mk 0.0 1.0 0.0,
    Vec3.mk 0.0 0.0 1.0
  ]
  let hull := ConvexHull3D.quickHull points
  ensure (hull.faceCount == 4) "tetrahedron should have 4 faces"

testSuite "Convex Decomposition"

test "decomposition splits separated triangles" := do
  let vertices := #[
    Vec3.mk 0.0 0.0 0.0,
    Vec3.mk 1.0 0.0 0.0,
    Vec3.mk 0.0 1.0 0.0,
    Vec3.mk 10.0 0.0 0.0,
    Vec3.mk 11.0 0.0 0.0,
    Vec3.mk 10.0 1.0 0.0
  ]
  let indices := #[0, 1, 2, 3, 4, 5]
  let mesh : Mesh := { vertices, indices }
  let config : ConvexDecompositionConfig := { maxTrianglesPerPart := 1, maxDepth := 4 }
  let parts := ConvexDecomposition.decompose mesh config
  ensure (parts.size == 2) "should split into 2 parts"
  if parts.size == 2 then
    let c0 := parts[0]!.bounds.center
    let c1 := parts[1]!.bounds.center
    ensure (c0.distance c1 > 5.0) "parts should be far apart"
  else
    pure ()

test "decomposition of empty mesh is empty" := do
  let mesh : Mesh := { vertices := #[], indices := #[] }
  let parts := ConvexDecomposition.decompose mesh
  ensure (parts.isEmpty) "empty mesh should produce no parts"

testSuite "Convex Decomposition Exact"

test "exact decomposition preserves area while splitting" := do
  let vertices := #[
    Vec3.mk (-1.0) 0.0 0.0,
    Vec3.mk 1.0 0.0 0.0,
    Vec3.mk 1.0 1.0 0.0,
    Vec3.mk (-1.0) 1.0 0.0
  ]
  let indices := #[0, 1, 2, 0, 2, 3]
  let mesh : Mesh := { vertices, indices }
  let config : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 6
    minSplitExtent := 0.01
    maxConcavity := 0.0
    splitEpsilon := 1e-6
  }
  let parts := ConvexDecompositionExact.decompose mesh config
  ensure (!parts.isEmpty) "expected split parts"
  let totalArea := parts.foldl (fun acc piece => acc + meshArea piece.mesh) 0.0
  let originalArea := meshArea mesh
  let relErr := if originalArea > 1e-6 then Float.abs' (totalArea - originalArea) / originalArea else 0.0
  ensure (relErr <= 1e-5) "piece areas should sum to original area"
  for piece in parts do
    ensure piece.mesh.isValid "piece mesh should be valid"
    ensure (piece.mesh.triangleCount > 0) "piece should have triangles"

test "exact decomposition rejects invalid mesh" := do
  let mesh : Mesh := {
    vertices := #[Vec3.mk 0.0 0.0 0.0]
    indices := #[0, 1, 2]
  }
  let parts := ConvexDecompositionExact.decompose mesh
  ensure parts.isEmpty "invalid mesh should produce no parts"

test "exact decomposition sampled coverage is complete" := do
  let mesh := crossingQuadMesh
  let config : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 6
    minSplitExtent := 1e-4
    maxConcavity := -1.0
    splitEpsilon := 1e-6
  }
  let parts := ConvexDecompositionExact.decompose mesh config
  ensure (parts.size >= 2) "expected at least two exact pieces"
  let samples := surfaceSamples mesh
  ensure (!samples.isEmpty) "expected surface samples"
  let mut minCoverage := Nat.succ samples.size
  let mut maxCoverage := 0
  for p in samples do
    let n := coveringPieceCount parts p 1e-6
    if n < minCoverage then
      minCoverage := n
    if n > maxCoverage then
      maxCoverage := n
  ensure (minCoverage >= 1) "each surface sample should belong to at least one exact piece"

test "exact decomposition obeys maxDepth cap" := do
  let config : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 0
    minSplitExtent := 0.001
    maxConcavity := -1.0
  }
  let parts := ConvexDecompositionExact.decompose bridgeMesh config
  ensure (parts.size == 1) "maxDepth=0 should prevent splitting"

test "exact decomposition maxTrianglesPerPart=0 still allows concavity splitting" := do
  let config : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 0
    maxDepth := 8
    minSplitExtent := 0.01
    maxConcavity := 0.0
  }
  let parts := ConvexDecompositionExact.decompose bridgeMesh config
  ensure (parts.size > 1) "no triangle cap should still split on concavity"

test "exact decomposition honors maxConcavity threshold" := do
  let splitConfig : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 8
    minSplitExtent := 0.01
    maxConcavity := 0.0
  }
  let stopConfig : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 8
    minSplitExtent := 0.01
    maxConcavity := 10.0
  }
  let splitParts := ConvexDecompositionExact.decompose bridgeMesh splitConfig
  let stopParts := ConvexDecompositionExact.decompose bridgeMesh stopConfig
  ensure (splitParts.size > 1) "low concavity threshold should split bridge mesh"
  ensure (stopParts.size == 1) "high concavity threshold should stop splitting"

test "exact decomposition honors minSplitExtent threshold" := do
  let stopConfig : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 6
    minSplitExtent := 0.1
    maxConcavity := -1.0
  }
  let splitConfig : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 6
    minSplitExtent := 1e-6
    maxConcavity := -1.0
  }
  let stopParts := ConvexDecompositionExact.decompose tinyExtentMesh stopConfig
  let splitParts := ConvexDecompositionExact.decompose tinyExtentMesh splitConfig
  ensure (stopParts.size == 1) "large minSplitExtent should block splitting"
  ensure (splitParts.size >= 2) "small minSplitExtent should allow splitting"

test "exact decomposition is robust near split plane" := do
  let mesh := splitPlaneStressMesh
  let config : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 1
    maxDepth := 6
    minSplitExtent := 1e-7
    maxConcavity := -1.0
    splitEpsilon := 1e-7
  }
  let parts := ConvexDecompositionExact.decompose mesh config
  ensure (!parts.isEmpty) "expected non-empty decomposition"
  for piece in parts do
    ensure piece.mesh.isValid "split piece must remain valid"
    for i in [:piece.mesh.triangleCount] do
      match Mesh.triangle? piece.mesh i with
      | none => ensure false "piece triangle index should be valid"
      | some tri => ensure (tri.area > 1e-10) "split should not emit degenerate triangles"
  let totalArea := parts.foldl (fun acc piece => acc + meshArea piece.mesh) 0.0
  let originalArea := meshArea mesh
  let relErr := if originalArea > 1e-6 then Float.abs' (totalArea - originalArea) / originalArea else 0.0
  ensure (relErr <= 1e-4) "near-plane splitting should preserve area"

test "exact piece hull contains all piece vertices" := do
  let config : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 2
    maxDepth := 8
    minSplitExtent := 0.01
    maxConcavity := 0.0
  }
  let parts := ConvexDecompositionExact.decompose bridgeMesh config
  ensure (!parts.isEmpty) "expected decomposition pieces"
  for piece in parts do
    ensure (piece.hull.points.size > 0) "piece hull should have points"
    for v in piece.mesh.vertices do
      ensure (hullContainsPointTol piece.hull v 2e-3) "piece vertex should lie in piece hull"

test "proxy hulls overlap more than exact surfaces on samples" := do
  let mesh := bridgeMesh
  let proxyCfg : ConvexDecompositionConfig := {
    maxTrianglesPerPart := 2
    maxDepth := 8
    minSplitExtent := 0.01
  }
  let exactCfg : ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 2
    maxDepth := 8
    minSplitExtent := 0.01
    maxConcavity := 0.0
  }
  let proxyPieces := ConvexDecomposition.decompose mesh proxyCfg
  let exactPieces := ConvexDecompositionExact.decompose mesh exactCfg
  ensure (!proxyPieces.isEmpty && !exactPieces.isEmpty) "expected both decompositions to produce pieces"
  let samples := surfaceSamples mesh
  ensure (!samples.isEmpty) "expected samples from source surface"
  let mut sawProxyOverlap := false
  let mut maxProxyCoverage := 0
  let mut maxExactCoverage := 0
  for p in samples do
    let proxyCoverage := coveringProxyPieceCount proxyPieces p 1e-4
    let exactCoverage := coveringPieceCount exactPieces p 1e-6
    if proxyCoverage > maxProxyCoverage then
      maxProxyCoverage := proxyCoverage
    if proxyCoverage > 1 then
      sawProxyOverlap := true
    if exactCoverage > maxExactCoverage then
      maxExactCoverage := exactCoverage
  ensure sawProxyOverlap "expected overlapping proxy hull coverage on source samples"
  ensure (maxProxyCoverage > maxExactCoverage) "proxy hull coverage should overlap more than exact surface coverage"

testSuite "Collision3D"

test "GJK3D AABB-AABB intersects" := do
  let a := AABB.fromMinMax Vec3.zero (Vec3.mk 1.0 1.0 1.0)
  let b := AABB.fromMinMax (Vec3.mk 0.5 0.5 0.5) (Vec3.mk 1.5 1.5 1.5)
  ensure (intersectsGJK3D a b) "AABBs should intersect"

test "GJK3D AABB-AABB no intersection" := do
  let a := AABB.fromMinMax Vec3.zero (Vec3.mk 1.0 1.0 1.0)
  let b := AABB.fromMinMax (Vec3.mk 3.0 3.0 3.0) (Vec3.mk 4.0 4.0 4.0)
  ensure (!(intersectsGJK3D a b)) "AABBs should not intersect"



end LinalgTests.GeometryTests
