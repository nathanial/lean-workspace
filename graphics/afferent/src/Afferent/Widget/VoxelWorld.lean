/-
  VoxelWorld widget utilities.

  Provides:
  - A chunked procedural voxel terrain mesh generator
  - A reusable 3D voxel mesh renderer
  - Arbor `custom` / `namedCustom` widget constructors for voxel scenes
-/
import Afferent.UI.Arbor
import Afferent.Core.Transform
import Afferent.Graphics.Canvas.Context
import Afferent.Graphics.Render.FPSCamera
import Afferent.Runtime.FFI.Renderer3D
import Linalg
import Trellis

namespace Afferent.Widget

open Afferent
open Afferent.FFI
open Afferent.Render
open Afferent.CanvasM
open Linalg

/-- RGBA color used for voxel mesh generation. -/
structure VoxelColor where
  r : Float
  g : Float
  b : Float
  a : Float := 1.0
  deriving Repr, Inhabited

/-- Generated voxel mesh data (10 floats per vertex, indexed triangles). -/
structure VoxelMesh where
  vertices : Array Float := #[]
  indices : Array UInt32 := #[]
  deriving Repr, Inhabited

/-- Palette used for procedural chunked terrain. -/
inductive VoxelPalette where
  | terrain
  | canyon
  | chunkDebug
  deriving Repr, Inhabited, BEq

/-- Parameters for procedural chunked voxel terrain generation. -/
structure ChunkedTerrainParams where
  chunkRadius : Nat := 1
  chunkSize : Nat := 16
  chunkHeight : Nat := 24
  baseHeight : Nat := 5
  heightRange : Nat := 14
  frequency : Float := 0.17
  terraceStep : Nat := 1
  palette : VoxelPalette := .terrain
  showChunkBoundaries : Bool := true
  deriving Repr, Inhabited

/-- Rendering configuration for voxel scenes. -/
structure VoxelSceneConfig where
  fovY : Float := Float.pi / 3.0
  nearPlane : Float := 0.1
  farPlane : Float := 600.0
  lightDir : Array Float := #[0.45, 0.85, 0.35]
  ambient : Float := 0.45
  fogColor : Array Float := #[0.06, 0.08, 0.12]
  fogStart : Float := 45.0
  fogEnd : Float := 160.0
  deriving Repr, Inhabited

private def intToFloat (i : Int) : Float :=
  if i >= 0 then i.toNat.toFloat else -((-i).toNat.toFloat)

private inductive Face where
  | top
  | bottom
  | north
  | south
  | east
  | west

private def allFaces : Array Face := #[
  .top, .bottom, .north, .south, .east, .west
]

private def faceData (face : Face) : (Array (Float × Float × Float)) × (Float × Float × Float) × (Int × Int × Int) :=
  match face with
  | .top =>
      (#[(0, 1, 0), (1, 1, 0), (1, 1, 1), (0, 1, 1)], (0.0, 1.0, 0.0), (0, 1, 0))
  | .bottom =>
      (#[(0, 0, 1), (1, 0, 1), (1, 0, 0), (0, 0, 0)], (0.0, -1.0, 0.0), (0, -1, 0))
  | .north =>
      (#[(1, 0, 1), (0, 0, 1), (0, 1, 1), (1, 1, 1)], (0.0, 0.0, 1.0), (0, 0, 1))
  | .south =>
      (#[(0, 0, 0), (1, 0, 0), (1, 1, 0), (0, 1, 0)], (0.0, 0.0, -1.0), (0, 0, -1))
  | .east =>
      (#[(1, 0, 0), (1, 0, 1), (1, 1, 1), (1, 1, 0)], (1.0, 0.0, 0.0), (1, 0, 0))
  | .west =>
      (#[(0, 0, 1), (0, 0, 0), (0, 1, 0), (0, 1, 1)], (-1.0, 0.0, 0.0), (-1, 0, 0))

private def pushFace (vertices : Array Float) (indices : Array UInt32)
    (baseVertex : Nat) (wx wy wz : Float)
    (face : Face) (color : VoxelColor) : Array Float × Array UInt32 := Id.run do
  let (corners, (nx, ny, nz), _) := faceData face
  let mut verts := vertices
  for (dx, dy, dz) in corners do
    verts := verts.push (wx + dx)
    verts := verts.push (wy + dy)
    verts := verts.push (wz + dz)
    verts := verts.push nx
    verts := verts.push ny
    verts := verts.push nz
    verts := verts.push color.r
    verts := verts.push color.g
    verts := verts.push color.b
    verts := verts.push color.a
  let vi := baseVertex.toUInt32
  let mut inds := indices
  inds := inds.push vi
  inds := inds.push (vi + 1)
  inds := inds.push (vi + 2)
  inds := inds.push vi
  inds := inds.push (vi + 2)
  inds := inds.push (vi + 3)
  (verts, inds)

private def paletteColor (palette : VoxelPalette)
    (chunkX chunkZ : Nat) (yNat surfaceY maxY : Nat) : VoxelColor :=
  match palette with
  | .terrain =>
      if yNat + 1 >= surfaceY then
        { r := 0.33, g := 0.72, b := 0.29 }
      else if yNat + 4 >= surfaceY then
        { r := 0.50, g := 0.36, b := 0.24 }
      else
        { r := 0.43, g := 0.45, b := 0.49 }
  | .canyon =>
      let denom := (Nat.max 1 maxY).toFloat
      let t := Float.clamp (yNat.toFloat / denom) 0.0 1.0
      {
        r := 0.35 + 0.42 * t
        g := 0.18 + 0.34 * t
        b := 0.12 + 0.20 * t
        a := 1.0
      }
  | .chunkDebug =>
      let k := (chunkX + chunkZ * 3) % 6
      let (r, g, b) :=
        match k with
        | 0 => (0.95, 0.35, 0.34)
        | 1 => (0.31, 0.72, 0.94)
        | 2 => (0.41, 0.83, 0.45)
        | 3 => (0.93, 0.74, 0.32)
        | 4 => (0.77, 0.49, 0.92)
        | _ => (0.33, 0.91, 0.84)
      if yNat + 1 >= surfaceY then
        { r := Float.min 1.0 (r + 0.15), g := Float.min 1.0 (g + 0.15), b := Float.min 1.0 (b + 0.15), a := 1.0 }
      else
        { r := r * 0.72, g := g * 0.72, b := b * 0.72, a := 1.0 }

/-- Generate a chunked voxel terrain mesh with face culling. -/
def generateChunkedTerrainMesh (params : ChunkedTerrainParams := {}) : VoxelMesh := Id.run do
  let safeChunkSize := Nat.max 1 params.chunkSize
  let safeChunkHeight := Nat.max 1 params.chunkHeight
  let chunkCount := params.chunkRadius * 2 + 1
  let worldSpan := chunkCount * safeChunkSize
  let minX : Int := -(Int.ofNat (params.chunkRadius * safeChunkSize))
  let minZ : Int := minX
  let maxX : Int := minX + Int.ofNat worldSpan - 1
  let maxZ : Int := minZ + Int.ofNat worldSpan - 1
  let maxYNat := safeChunkHeight - 1
  let terrace := Nat.max 1 params.terraceStep

  let heightAt : Int → Int → Nat := fun x z =>
    let xf := intToFloat x * params.frequency
    let zf := intToFloat z * params.frequency
    let wave := (Float.sin xf + Float.cos zf + Float.sin (xf * 0.7 + zf * 1.1)) / 3.0
    let normalized := Float.clamp ((wave + 1.0) * 0.5) 0.0 1.0
    let rawHeight := params.baseHeight.toFloat + normalized * params.heightRange.toFloat
    let base := rawHeight.floor.toUInt64.toNat
    let terraced := if terrace <= 1 then base else (base / terrace) * terrace
    Nat.min maxYNat terraced

  let inBounds : Int → Int → Int → Bool := fun x y z =>
    x >= minX && x <= maxX &&
    z >= minZ && z <= maxZ &&
    y >= 0 && y < Int.ofNat safeChunkHeight

  let solidAt : Int → Int → Int → Bool := fun x y z =>
    if !inBounds x y z then
      false
    else
      y.toNat <= heightAt x z

  let colorAt : Int → Int → Int → VoxelColor := fun x y z =>
    let relX := (x - minX).toNat
    let relZ := (z - minZ).toNat
    let chunkX := relX / safeChunkSize
    let chunkZ := relZ / safeChunkSize
    let surface := heightAt x z
    let yNat := y.toNat
    let baseColor := paletteColor params.palette chunkX chunkZ yNat surface maxYNat
    if params.showChunkBoundaries && yNat + 1 >= surface then
      let localX := relX % safeChunkSize
      let localZ := relZ % safeChunkSize
      let onBoundary :=
        localX == 0 || localZ == 0 ||
        localX + 1 == safeChunkSize || localZ + 1 == safeChunkSize
      if onBoundary then
        { baseColor with
          r := baseColor.r * 0.55
          g := baseColor.g * 0.55
          b := baseColor.b * 0.55
        }
      else
        baseColor
    else
      baseColor

  let mut vertices : Array Float := #[]
  let mut indices : Array UInt32 := #[]
  let mut vertexCount : Nat := 0

  for yi in [:safeChunkHeight] do
    let y : Int := Int.ofNat yi
    for zi in [:worldSpan] do
      let z : Int := minZ + Int.ofNat zi
      for xi in [:worldSpan] do
        let x : Int := minX + Int.ofNat xi
        if solidAt x y z then
          let wx := intToFloat x
          let wy := yi.toFloat
          let wz := intToFloat z
          let color := colorAt x y z
          for face in allFaces do
            let (_, _, (dx, dy, dz)) := faceData face
            if !solidAt (x + dx) (y + dy) (z + dz) then
              let (verts', inds') := pushFace vertices indices vertexCount wx wy wz face color
              vertices := verts'
              indices := inds'
              vertexCount := vertexCount + 4

  { vertices, indices }

/-- Render a pre-built voxel mesh to a viewport using an FPS camera. -/
def renderVoxelMesh (renderer : FFI.Renderer) (width height : Float)
    (camera : FPSCamera) (mesh : VoxelMesh) (config : VoxelSceneConfig := {}) : IO Unit := do
  if width <= 0.0 || height <= 0.0 || mesh.indices.isEmpty then
    pure ()
  else
    let aspect := width / height
    let proj := Mat4.perspective config.fovY aspect config.nearPlane config.farPlane
    let view := camera.viewMatrix
    let model := Mat4.identity
    let mvp := proj * view * model
    let cameraPos := #[camera.x, camera.y, camera.z]
    Renderer.drawMesh3D
      renderer
      mesh.vertices
      mesh.indices
      mvp.toArray
      model.toArray
      config.lightDir
      config.ambient
      cameraPos
      config.fogColor
      config.fogStart
      config.fogEnd

private def withContentRect (layout : Trellis.ComputedLayout)
    (draw : Float → Float → CanvasM Unit) : CanvasM Unit := do
  let rect := layout.contentRect
  save
  setBaseTransform (Transform.translate rect.x rect.y)
  resetTransform
  clip (Rect.mk' 0 0 rect.width rect.height)
  draw rect.width rect.height
  restore

/-- Create a voxel-world custom widget. -/
private def defaultVoxelWorldStyle : Afferent.Arbor.BoxStyle := {
  flexItem := some (Trellis.FlexItem.growing 1)
}

def voxelWorldWidget (mesh : VoxelMesh) (camera : FPSCamera)
    (config : VoxelSceneConfig := {})
    (style : Afferent.Arbor.BoxStyle := defaultVoxelWorldStyle) : Afferent.Arbor.WidgetBuilder := do
  Arbor.custom (spec := {
    measure := fun _ _ => (0, 0)
    collect := fun _ => #[]
    draw := some (fun layout => do
      withContentRect layout fun w h => do
        resetTransform
        let renderer ← getRenderer
        renderVoxelMesh renderer w h camera mesh config
    )
    skipCache := true
  }) style

/-- Create a named voxel-world custom widget for hit-testing and event routing. -/
def namedVoxelWorldWidget (name : Arbor.ComponentId)
    (mesh : VoxelMesh) (camera : FPSCamera)
    (config : VoxelSceneConfig := {})
    (style : Afferent.Arbor.BoxStyle := defaultVoxelWorldStyle) : Afferent.Arbor.WidgetBuilder := do
  Arbor.namedCustom name (spec := {
    measure := fun _ _ => (0, 0)
    collect := fun _ => #[]
    draw := some (fun layout => do
      withContentRect layout fun w h => do
        resetTransform
        let renderer ← getRenderer
        renderVoxelMesh renderer w h camera mesh config
    )
    skipCache := true
  }) style

end Afferent.Widget
