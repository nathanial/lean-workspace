/-
  Convex Decomposition (Exact BSP) Demo - visualize disjoint piece meshes and hulls.
-/
import Afferent
import Afferent.UI.Widget
import Afferent.UI.Arbor
import Demos.Core.Demo
import Demos.Linalg.Shared
import Trellis
import Linalg.Core
import Linalg.Vec3
import Linalg.Mat4
import Linalg.Geometry.Mesh
import Linalg.Geometry.AABB
import Linalg.Geometry.ConvexHull3D
import Linalg.Geometry.ConvexDecompositionExact
import AfferentMath.Widget.MathView3D

open Afferent CanvasM Linalg
open Afferent.Widget
open AfferentMath.Widget

namespace Demos.Linalg

inductive ExactConvexMeshPreset where
  | cluster
  | stairs
  | bridge
  deriving BEq, Inhabited

def exactConvexMeshPresetName : ExactConvexMeshPreset → String
  | .cluster => "Cluster"
  | .stairs => "Stairs"
  | .bridge => "Bridge"

def nextExactConvexMeshPreset : ExactConvexMeshPreset → ExactConvexMeshPreset
  | .cluster => .stairs
  | .stairs => .bridge
  | .bridge => .cluster

/-- State for exact convex decomposition demo. -/
structure ConvexDecompositionExactState where
  cameraYaw : Float := 0.6
  cameraPitch : Float := 0.35
  dragging : Bool := false
  lastMouseX : Float := 0.0
  lastMouseY : Float := 0.0
  showMesh : Bool := true
  showPieceMeshes : Bool := true
  showHulls : Bool := false
  showBounds : Bool := true
  showAxes : Bool := true
  showGrid : Bool := true
  meshPreset : ExactConvexMeshPreset := .cluster
  config : Linalg.ExactConvexDecompositionConfig := {
    maxTrianglesPerPart := 20
    maxDepth := 8
    minSplitExtent := 0.12
    maxConcavity := 0.03
    splitEpsilon := 1e-5
  }
  deriving Inhabited

def convexDecompositionExactInitialState : ConvexDecompositionExactState := {}

def convexDecompositionExactMathViewConfig (state : ConvexDecompositionExactState) (screenScale : Float)
    : MathView3D.Config := {
  style := { flexItem := some (Trellis.FlexItem.growing 1) }
  camera := { yaw := state.cameraYaw, pitch := state.cameraPitch, distance := 7.0 }
  fov := 60.0 * Float.pi / 180.0
  showGrid := false
  showAxes := false
  axisLineWidth := 2.0 * screenScale
}

private def appendBox (verts : Array Vec3) (inds : Array Nat)
    (center extents : Vec3) : Array Vec3 × Array Nat := Id.run do
  let min := center.sub extents
  let max := center.add extents
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

private def buildMeshForPreset (preset : ExactConvexMeshPreset) : Mesh := Id.run do
  let mut verts : Array Vec3 := #[]
  let mut inds : Array Nat := #[]
  match preset with
  | .cluster =>
      let (v0, i0) := appendBox verts inds (Vec3.mk 0.0 0.0 0.0) (Vec3.mk 0.9 0.3 0.6)
      verts := v0
      inds := i0
      let (v1, i1) := appendBox verts inds (Vec3.mk 1.2 0.2 (-0.4)) (Vec3.mk 0.4 0.5 0.4)
      verts := v1
      inds := i1
      let (v2, i2) := appendBox verts inds (Vec3.mk (-1.1) 0.25 0.8) (Vec3.mk 0.5 0.35 0.5)
      verts := v2
      inds := i2
      let (v3, i3) := appendBox verts inds (Vec3.mk 0.2 0.95 0.2) (Vec3.mk 0.3 0.5 0.3)
      verts := v3
      inds := i3
      let (v4, i4) := appendBox verts inds (Vec3.mk (-0.6) 0.55 (-1.0)) (Vec3.mk 0.45 0.35 0.45)
      verts := v4
      inds := i4
  | .stairs =>
      for i in [:6] do
        let t := i.toFloat
        let center := Vec3.mk (-1.7 + t * 0.7) (0.15 + t * 0.22) (Float.sin (t * 0.6) * 0.3)
        let extents := Vec3.mk 0.4 (0.18 + t * 0.03) 0.55
        let (v, i2) := appendBox verts inds center extents
        verts := v
        inds := i2
  | .bridge =>
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

private def piecePalette : Array Color := #[
  Color.rgba 0.2 0.8 1.0 0.92,
  Color.rgba 0.9 0.6 0.2 0.92,
  Color.rgba 0.4 0.9 0.4 0.92,
  Color.rgba 0.9 0.35 0.4 0.92,
  Color.rgba 0.7 0.6 1.0 0.92,
  Color.rgba 0.3 0.9 0.7 0.92,
  Color.rgba 0.9 0.8 0.3 0.92,
  Color.rgba 0.5 0.85 0.95 0.92
]

private def pieceColor (idx : Nat) : Color :=
  piecePalette[idx % piecePalette.size]!

private abbrev ProjectionCtx := MathView3D.View

private def makeProjectionCtx (state : ConvexDecompositionExactState) (screenScale : Float)
    (w h : Float) : ProjectionCtx :=
  let config := convexDecompositionExactMathViewConfig state screenScale
  MathView3D.viewForSize config w h

private def projectPoint (ctx : ProjectionCtx) (p : Vec3) : Float × Float :=
  MathView3D.worldToScreen ctx p |>.getD (0.0, 0.0)

private def drawLine3D (a b : Vec3) (ctx : ProjectionCtx)
    (color : Color) (lineWidth : Float := 1.6) : CanvasM Unit := do
  MathView3D.drawLine3D ctx a b color lineWidth

private def drawAABBWireframe (aabb : AABB) (ctx : ProjectionCtx)
    (color : Color) (lineWidth : Float := 1.2) : CanvasM Unit := do
  let min := aabb.min
  let max := aabb.max
  let corners : Array Vec3 := #[
    Vec3.mk min.x min.y min.z,
    Vec3.mk max.x min.y min.z,
    Vec3.mk max.x max.y min.z,
    Vec3.mk min.x max.y min.z,
    Vec3.mk min.x min.y max.z,
    Vec3.mk max.x min.y max.z,
    Vec3.mk max.x max.y max.z,
    Vec3.mk min.x max.y max.z
  ]
  let edges : Array (Nat × Nat) := #[(0, 1), (1, 2), (2, 3), (3, 0), (4, 5), (5, 6),
    (6, 7), (7, 4), (0, 4), (1, 5), (2, 6), (3, 7)]
  for (i, j) in edges do
    drawLine3D (corners.getD i Vec3.zero) (corners.getD j Vec3.zero) ctx color lineWidth

private def collectHullEdges (faces : Array (Nat × Nat × Nat)) : Array (Nat × Nat) := Id.run do
  let mut edges : Array (Nat × Nat) := #[]
  let mut keys : Array (Nat × Nat) := #[]
  for (a, b, c) in faces do
    let key1 := if a <= b then (a, b) else (b, a)
    if !keys.any (fun k => k == key1) then
      keys := keys.push key1
      edges := edges.push (a, b)
    let key2 := if b <= c then (b, c) else (c, b)
    if !keys.any (fun k => k == key2) then
      keys := keys.push key2
      edges := edges.push (b, c)
    let key3 := if c <= a then (c, a) else (a, c)
    if !keys.any (fun k => k == key3) then
      keys := keys.push key3
      edges := edges.push (c, a)
  return edges

private def drawHullWireframe (hull : ConvexHull3D) (ctx : ProjectionCtx)
    (color : Color) : CanvasM Unit := do
  if hull.faces.isEmpty then return
  let edges := collectHullEdges hull.faces
  for (a, b) in edges do
    let p1 := hull.points.getD a Vec3.zero
    let p2 := hull.points.getD b Vec3.zero
    drawLine3D p1 p2 ctx color 1.6

private def drawMeshWireframe (mesh : Mesh) (ctx : ProjectionCtx)
    (color : Color) (lineWidth : Float := 1.1) : CanvasM Unit := do
  for i in [:mesh.triangleCount] do
    match Mesh.triangle? mesh i with
    | none => pure ()
    | some tri =>
      drawLine3D tri.v0 tri.v1 ctx color lineWidth
      drawLine3D tri.v1 tri.v2 ctx color lineWidth
      drawLine3D tri.v2 tri.v0 ctx color lineWidth

private def drawGroundGrid (ctx : ProjectionCtx) (screenScale : Float) : CanvasM Unit := do
  setStrokeColor (Color.gray 0.18)
  setLineWidth (1.0 * screenScale)
  for i in [:13] do
    let offset := (i.toFloat - 6.0) * 0.6
    let p1 := projectPoint ctx (Vec3.mk (-3.6) 0 offset)
    let p2 := projectPoint ctx (Vec3.mk 3.6 0 offset)
    let path := Afferent.Path.empty
      |>.moveTo (Point.mk p1.1 p1.2)
      |>.lineTo (Point.mk p2.1 p2.2)
    strokePath path
    let p3 := projectPoint ctx (Vec3.mk offset 0 (-3.6))
    let p4 := projectPoint ctx (Vec3.mk offset 0 3.6)
    let path2 := Afferent.Path.empty
      |>.moveTo (Point.mk p3.1 p3.2)
      |>.lineTo (Point.mk p4.1 p4.2)
    strokePath path2

private def drawAxesPerspective (ctx : ProjectionCtx) (axisLength : Float)
    (fontSmall : Font) : CanvasM Unit := do
  let xEnd := Vec3.mk axisLength 0.0 0.0
  let yEnd := Vec3.mk 0.0 axisLength 0.0
  let zEnd := Vec3.mk 0.0 0.0 axisLength

  drawLine3D Vec3.zero xEnd ctx VecColor.xAxis 2.0
  drawLine3D Vec3.zero yEnd ctx VecColor.yAxis 2.0
  drawLine3D Vec3.zero zEnd ctx VecColor.zAxis 2.0

  let (xx, xy) := projectPoint ctx xEnd
  let (yx, yy) := projectPoint ctx yEnd
  let (zx, zy) := projectPoint ctx zEnd

  setFillColor VecColor.xAxis
  fillTextXY "X" (xx + 6) (xy - 6) fontSmall
  setFillColor VecColor.yAxis
  fillTextXY "Y" (yx + 6) (yy - 6) fontSmall
  setFillColor VecColor.zAxis
  fillTextXY "Z" (zx + 6) (zy - 6) fontSmall

private def totalPieceTriangles (pieces : Array ExactConvexPiece) : Nat :=
  pieces.foldl (fun acc piece => acc + piece.mesh.triangleCount) 0

private def maxPieceConcavity (pieces : Array ExactConvexPiece) : Float :=
  pieces.foldl (fun acc piece => Float.max acc piece.concavity) 0.0

/-- Render exact convex decomposition demo. -/
def renderConvexDecompositionExact (state : ConvexDecompositionExactState)
    (view : MathView3D.View) (screenScale : Float) (fontMedium fontSmall : Font) : CanvasM Unit := do
  let w := view.width
  let h := view.height
  let projCtx := makeProjectionCtx state screenScale w h
  let mesh := buildMeshForPreset state.meshPreset
  let pieces := Linalg.ConvexDecompositionExact.decompose mesh state.config
  let pieceTriCount := totalPieceTriangles pieces
  let maxConcavity := maxPieceConcavity pieces

  if state.showGrid then
    drawGroundGrid projCtx screenScale
  if state.showAxes then
    drawAxesPerspective projCtx 2.8 fontSmall

  if state.showMesh then
    drawMeshWireframe mesh projCtx (Color.gray 0.24) 0.9

  for i in [:pieces.size] do
    let piece := pieces[i]!
    let color := pieceColor i
    if state.showPieceMeshes then
      drawMeshWireframe piece.mesh projCtx color 1.35
    if state.showHulls then
      drawHullWireframe piece.hull projCtx (color.withAlpha 0.8)
    if state.showBounds then
      drawAABBWireframe piece.bounds projCtx (color.withAlpha 0.3) 1.1

  let infoY := h - 190 * screenScale
  let maxTriText := if state.config.maxTrianglesPerPart == 0 then "none"
    else s!"{state.config.maxTrianglesPerPart}"
  setFillColor VecColor.label
  fillTextXY
    s!"mesh: {exactConvexMeshPresetName state.meshPreset}  source tris: {mesh.triangleCount}  pieces: {pieces.size}"
    (20 * screenScale) infoY fontSmall
  fillTextXY
    s!"piece tris total: {pieceTriCount}  max piece concavity: {formatFloat maxConcavity}"
    (20 * screenScale) (infoY + 20 * screenScale) fontSmall
  fillTextXY
    s!"max tris/part: {maxTriText}  max depth: {state.config.maxDepth}"
    (20 * screenScale) (infoY + 40 * screenScale) fontSmall
  fillTextXY
    s!"min split: {formatFloat state.config.minSplitExtent}  max concavity: {formatFloat state.config.maxConcavity}"
    (20 * screenScale) (infoY + 60 * screenScale) fontSmall
  fillTextXY
    s!"hulls: {state.showHulls}  bounds: {state.showBounds}  mesh: {state.showMesh}  piece mesh: {state.showPieceMeshes}"
    (20 * screenScale) (infoY + 80 * screenScale) fontSmall

  fillTextXY "CONVEX DECOMPOSITION (EXACT BSP)" (20 * screenScale) (30 * screenScale) fontMedium
  setFillColor (Color.gray 0.6)
  fillTextXY
    "Drag: rotate | C: preset | M: source mesh | P: piece mesh | H: hulls | B: bounds"
    (20 * screenScale) (55 * screenScale) fontSmall
  fillTextXY
    "[ ]: tris/part | , .: depth | +/-: split extent | I/K: concavity | G/X: grid/axes | R: reset"
    (20 * screenScale) (75 * screenScale) fontSmall

/-- Create the exact convex decomposition widget. -/
def convexDecompositionExactWidget (env : DemoEnv) (state : ConvexDecompositionExactState)
    : Afferent.Arbor.WidgetBuilder := do
  let config := convexDecompositionExactMathViewConfig state env.screenScale
  MathView3D.mathView3D config env.fontSmall (fun view => do
    renderConvexDecompositionExact state view env.screenScale env.fontMedium env.fontSmall
  )

end Demos.Linalg
