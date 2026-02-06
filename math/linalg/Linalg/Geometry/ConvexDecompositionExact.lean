/-
  Exact-ish convex decomposition for triangle meshes (3D).

  Unlike centroid-cluster proxy decomposition, this variant splits by clipping
  triangles against BSP planes, so piece meshes are disjoint surface partitions.
  It then computes a convex hull for each piece and recurses until piece
  concavity/limits are met.
-/

import Linalg.Geometry.Mesh
import Linalg.Geometry.ConvexHull3D
import Linalg.Geometry.AABB

namespace Linalg

/-- A convex piece produced by exact decomposition. -/
structure ExactConvexPiece where
  mesh : Mesh
  hull : ConvexHull3D
  bounds : AABB
  concavity : Float
  deriving Repr, Inhabited

namespace ExactConvexPiece

/-- Number of triangles in this piece mesh. -/
@[inline]
def triangleCount (piece : ExactConvexPiece) : Nat :=
  piece.mesh.triangleCount

end ExactConvexPiece

/-- Configuration for exact convex decomposition. -/
structure ExactConvexDecompositionConfig where
  /-- Max triangles per convex piece (0 = no limit). -/
  maxTrianglesPerPart : Nat := 48
  /-- Max recursion depth. -/
  maxDepth : Nat := 12
  /-- Minimum centroid extent to allow splitting. -/
  minSplitExtent : Float := 0.02
  /-- Stop splitting when piece concavity is below this threshold. -/
  maxConcavity : Float := 0.02
  /-- Numerical epsilon used for plane-side tests while clipping. -/
  splitEpsilon : Float := 1e-5
  deriving Repr, BEq, Inhabited

namespace ConvexDecompositionExact

private structure PieceAnalysis where
  hull : ConvexHull3D
  bounds : AABB
  centroidBounds : AABB
  concavity : Float
  deriving Repr, Inhabited

private def axisValue (v : Vec3) (axis : Fin 3) : Float :=
  match axis with
  | ⟨0, _⟩ => v.x
  | ⟨1, _⟩ => v.y
  | ⟨2, _⟩ => v.z

private def axisExtent (b : AABB) (axis : Fin 3) : Float :=
  axisValue b.max axis - axisValue b.min axis

private def longestAxis (b : AABB) : Fin 3 :=
  let ex := b.max.x - b.min.x
  let ey := b.max.y - b.min.y
  let ez := b.max.z - b.min.z
  if ex >= ey && ex >= ez then ⟨0, by decide⟩
  else if ey >= ez then ⟨1, by decide⟩
  else ⟨2, by decide⟩

private def hullCentroid (hull : ConvexHull3D) : Vec3 :=
  if hull.points.isEmpty then
    Vec3.zero
  else
    let sum := hull.points.foldl (fun acc p => acc + p) Vec3.zero
    sum * (1.0 / hull.points.size.toFloat)

private def buildHullPlanes (hull : ConvexHull3D) : Array (Vec3 × Float) := Id.run do
  if hull.faces.isEmpty || hull.points.isEmpty then
    return #[]
  let center := hullCentroid hull
  let mut planes : Array (Vec3 × Float) := #[]
  for (a, b, c) in hull.faces do
    let p0 := hull.points.getD a Vec3.zero
    let p1 := hull.points.getD b Vec3.zero
    let p2 := hull.points.getD c Vec3.zero
    let mut normal := (p1 - p0).cross (p2 - p0)
    if normal.lengthSquared < 1e-9 then
      continue
    normal := normal.normalize
    if normal.dot (center - p0) > 0.0 then
      normal := -normal
    let offset := normal.dot p0
    planes := planes.push (normal, offset)
  return planes

private def hullSignedDistance (planes : Array (Vec3 × Float)) (p : Vec3) : Float := Id.run do
  if planes.isEmpty then
    return 0.0
  let mut maxDist := (-1.0e9)
  for (normal, offset) in planes do
    let dist := normal.dot p - offset
    if dist > maxDist then
      maxDist := dist
  return maxDist

private def concavityDistance (planes : Array (Vec3 × Float)) (p : Vec3) : Float :=
  let maxDist := hullSignedDistance planes p
  if maxDist < 0.0 then -maxDist else 0.0

private def pieceConcavity (mesh : Mesh) (hull : ConvexHull3D) : Float := Id.run do
  let planes := buildHullPlanes hull
  if planes.isEmpty then
    return 0.0
  let mut maxConcavity := 0.0
  for i in [:mesh.triangleCount] do
    match Mesh.triangle? mesh i with
    | none => ()
    | some tri =>
      let c0 := concavityDistance planes tri.v0
      let c1 := concavityDistance planes tri.v1
      let c2 := concavityDistance planes tri.v2
      let cc := concavityDistance planes tri.centroid
      maxConcavity := Float.max maxConcavity (Float.max c0 (Float.max c1 (Float.max c2 cc)))
  return maxConcavity

private def triangleCentroidBounds (mesh : Mesh) : AABB := Id.run do
  let mut found := false
  let mut bounds := AABB.fromPoint Vec3.zero
  for i in [:mesh.triangleCount] do
    match Mesh.triangle? mesh i with
    | none => ()
    | some tri =>
      let c := tri.centroid
      if !found then
        found := true
        bounds := AABB.fromPoint c
      else
        bounds := AABB.expand bounds c
  if found then bounds else mesh.bounds

private def analyzePiece (mesh : Mesh) : PieceAnalysis :=
  let hull := ConvexHull3D.quickHull mesh.vertices
  let bounds := mesh.bounds
  let centroidBounds := triangleCentroidBounds mesh
  let concavity := pieceConcavity mesh hull
  { hull, bounds, centroidBounds, concavity }

private def addTriangle (verts : Array Vec3) (inds : Array Nat)
    (a b c : Vec3) : Array Vec3 × Array Nat :=
  let n := (b - a).cross (c - a)
  if n.lengthSquared <= 1e-12 then
    (verts, inds)
  else
    let base := verts.size
    (verts.push a |>.push b |>.push c, inds.push base |>.push (base + 1) |>.push (base + 2))

private def intersectOnPlane (a b : Vec3) (da db : Float) : Vec3 :=
  let denom := da - db
  if Float.abs' denom <= 1e-9 then
    a
  else
    let t := Float.clamp (da / denom) 0.0 1.0
    a + (b - a) * t

private def clipPolygonByPlane (poly : Array Vec3) (split : Vec3 → Float)
    (inside : Float → Bool) : Array Vec3 := Id.run do
  if poly.isEmpty then
    return #[]
  let mut out : Array Vec3 := #[]
  let mut prev := poly[poly.size - 1]!
  let mut prevDist := split prev
  let mut prevInside := inside prevDist
  for curr in poly do
    let currDist := split curr
    let currInside := inside currDist
    if currInside then
      if !prevInside then
        out := out.push (intersectOnPlane prev curr prevDist currDist)
      out := out.push curr
    else if prevInside then
      out := out.push (intersectOnPlane prev curr prevDist currDist)
    prev := curr
    prevDist := currDist
    prevInside := currInside
  return out

private def triangulatePolygon (poly : Array Vec3) (verts : Array Vec3)
    (inds : Array Nat) : Array Vec3 × Array Nat := Id.run do
  if poly.size < 3 then
    return (verts, inds)
  let mut outVerts := verts
  let mut outInds := inds
  let p0 := poly[0]!
  for i in [1:poly.size - 1] do
    let p1 := poly[i]!
    let p2 := poly[i + 1]!
    let (nextVerts, nextInds) := addTriangle outVerts outInds p0 p1 p2
    outVerts := nextVerts
    outInds := nextInds
  return (outVerts, outInds)

private def splitMeshByPlane (mesh : Mesh) (axis : Fin 3) (splitValue : Float)
    (eps : Float) : Mesh × Mesh := Id.run do
  let mut leftVerts : Array Vec3 := #[]
  let mut leftInds : Array Nat := #[]
  let mut rightVerts : Array Vec3 := #[]
  let mut rightInds : Array Nat := #[]

  let sideDist := fun (p : Vec3) => axisValue p axis - splitValue

  for triIdx in [:mesh.triangleCount] do
    match Mesh.triangle? mesh triIdx with
    | none => ()
    | some tri =>
      let d0 := sideDist tri.v0
      let d1 := sideDist tri.v1
      let d2 := sideDist tri.v2
      let allLeft := d0 <= eps && d1 <= eps && d2 <= eps
      let allRight := d0 >= -eps && d1 >= -eps && d2 >= -eps
      if allLeft then
        let (v, i) := addTriangle leftVerts leftInds tri.v0 tri.v1 tri.v2
        leftVerts := v
        leftInds := i
      else if allRight then
        let (v, i) := addTriangle rightVerts rightInds tri.v0 tri.v1 tri.v2
        rightVerts := v
        rightInds := i
      else
        let poly : Array Vec3 := #[tri.v0, tri.v1, tri.v2]
        let leftPoly := clipPolygonByPlane poly sideDist (fun d => d <= eps)
        let rightPoly := clipPolygonByPlane poly sideDist (fun d => d >= -eps)
        let (lv, li) := triangulatePolygon leftPoly leftVerts leftInds
        leftVerts := lv
        leftInds := li
        let (rv, ri) := triangulatePolygon rightPoly rightVerts rightInds
        rightVerts := rv
        rightInds := ri

  return (Mesh.fromVerticesIndices leftVerts leftInds, Mesh.fromVerticesIndices rightVerts rightInds)

private def makePiece (mesh : Mesh) (analysis : PieceAnalysis) : ExactConvexPiece :=
  { mesh := mesh, hull := analysis.hull, bounds := analysis.bounds, concavity := analysis.concavity }

private partial def buildParts (mesh : Mesh) (depth : Nat)
    (config : ExactConvexDecompositionConfig) : Array ExactConvexPiece :=
  if mesh.triangleCount == 0 then
    #[]
  else
    let analysis := analyzePiece mesh
    let triCount := mesh.triangleCount
    let limit := if config.maxTrianglesPerPart == 0 then triCount else config.maxTrianglesPerPart
    if depth >= config.maxDepth || triCount <= limit || analysis.concavity <= config.maxConcavity then
      #[makePiece mesh analysis]
    else
      let axis := longestAxis analysis.centroidBounds
      let extent := axisExtent analysis.centroidBounds axis
      if extent < config.minSplitExtent then
        #[makePiece mesh analysis]
      else
        let minV := axisValue analysis.centroidBounds.min axis
        let maxV := axisValue analysis.centroidBounds.max axis
        let splitValue := (minV + maxV) * 0.5
        let (leftMesh, rightMesh) := splitMeshByPlane mesh axis splitValue config.splitEpsilon
        if leftMesh.triangleCount == 0 || rightMesh.triangleCount == 0 then
          #[makePiece mesh analysis]
        else
          buildParts leftMesh (depth + 1) config ++ buildParts rightMesh (depth + 1) config

/--
  Decompose a triangle mesh into convex pieces using BSP triangle clipping.
  Output piece meshes are disjoint surface partitions of the input mesh.
-/
def decompose (mesh : Mesh) (config : ExactConvexDecompositionConfig := {}) : Array ExactConvexPiece :=
  if !mesh.isValid || mesh.triangleCount == 0 then
    #[]
  else
    buildParts mesh 0 config

/-- Decompose and return only the convex hulls. -/
def decomposeHulls (mesh : Mesh) (config : ExactConvexDecompositionConfig := {}) : Array ConvexHull3D :=
  (decompose mesh config).map (·.hull)

end ConvexDecompositionExact

namespace Mesh

/-- Convenience wrapper for exact convex decomposition. -/
def convexDecomposeExact (mesh : Mesh) (config : ExactConvexDecompositionConfig := {})
    : Array ExactConvexPiece :=
  ConvexDecompositionExact.decompose mesh config

end Mesh

end Linalg
