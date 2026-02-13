/-
  Voxel world demo helpers built on `Afferent.Widget.VoxelWorld`.
-/
import Afferent
import Afferent.UI.Arbor
import Trellis

namespace Demos

open Afferent
open Afferent.Arbor
open Afferent.Render

structure VoxelWorldParams where
  chunkRadius : Nat := 1
  chunkHeight : Nat := 24
  baseHeight : Nat := 5
  heightRange : Nat := 14
  frequency : Float := 0.17
  terraceStep : Nat := 1
  palette : Afferent.Widget.VoxelPalette := .terrain
  mesher : Linalg.Voxel.MesherAlgorithm := .greedy
  fogEnabled : Bool := true
  showMesh : Bool := false
  showChunkBoundaries : Bool := true
  deriving Repr, Inhabited, BEq

def voxelWorldMinChunkRadius : Nat := 0
def voxelWorldMaxChunkRadius : Nat := 10

def voxelWorldChunkCount (radius : Nat) : Nat :=
  let span := radius * 2 + 1
  span * span

def voxelWorldInitialCamera : FPSCamera := {
  x := 0.0
  y := 24.0
  z := 40.0
  yaw := 0.0
  pitch := -0.45
  moveSpeed := 18.0
  lookSensitivity := 0.003
}

def voxelWorldPaletteLabel (palette : Afferent.Widget.VoxelPalette) : String :=
  match palette with
  | .terrain => "Terrain"
  | .canyon => "Canyon"
  | .chunkDebug => "Chunk Debug"

def voxelWorldNextPalette (palette : Afferent.Widget.VoxelPalette) : Afferent.Widget.VoxelPalette :=
  match palette with
  | .terrain => .canyon
  | .canyon => .chunkDebug
  | .chunkDebug => .terrain

def voxelWorldMesherLabel (mesher : Linalg.Voxel.MesherAlgorithm) : String :=
  match mesher with
  | .greedy => "Greedy"
  | .culled => "Culled"

def voxelWorldNextMesher (mesher : Linalg.Voxel.MesherAlgorithm) : Linalg.Voxel.MesherAlgorithm :=
  match mesher with
  | .greedy => .culled
  | .culled => .greedy

private def natToSlider (value lo hi : Nat) : Float :=
  if hi <= lo then 0.0
  else
    let clamped := Nat.max lo (Nat.min hi value)
    (clamped - lo).toFloat / (hi - lo).toFloat

private def sliderToNat (t : Float) (lo hi : Nat) : Nat :=
  if hi <= lo then lo
  else
    let clamped := Linalg.Float.clamp t 0.0 1.0
    let span := (hi - lo).toFloat
    let raw := (clamped * span + 0.5).floor.toUInt64.toNat
    Nat.min hi (lo + raw)

def voxelWorldRadiusToSlider (radius : Nat) : Float :=
  natToSlider radius voxelWorldMinChunkRadius voxelWorldMaxChunkRadius

def voxelWorldRadiusFromSlider (t : Float) : Nat :=
  sliderToNat t voxelWorldMinChunkRadius voxelWorldMaxChunkRadius

def voxelWorldHeightToSlider (height : Nat) : Float := natToSlider height 12 42
def voxelWorldHeightFromSlider (t : Float) : Nat := sliderToNat t 12 42

def voxelWorldBaseHeightToSlider (baseHeight : Nat) : Float := natToSlider baseHeight 2 18
def voxelWorldBaseHeightFromSlider (t : Float) : Nat := sliderToNat t 2 18

def voxelWorldRangeToSlider (heightRange : Nat) : Float := natToSlider heightRange 4 24
def voxelWorldRangeFromSlider (t : Float) : Nat := sliderToNat t 4 24

def voxelWorldTerraceToSlider (terraceStep : Nat) : Float := natToSlider terraceStep 1 6
def voxelWorldTerraceFromSlider (t : Float) : Nat := sliderToNat t 1 6

def voxelWorldFrequencyToSlider (frequency : Float) : Float :=
  Linalg.Float.clamp ((frequency - 0.06) / 0.28) 0.0 1.0

def voxelWorldFrequencyFromSlider (t : Float) : Float :=
  0.06 + Linalg.Float.clamp t 0.0 1.0 * 0.28

private def intToFloat (i : Int) : Float :=
  if i >= 0 then i.toNat.toFloat else -((-i).toNat.toFloat)

private def paletteColor (palette : Afferent.Widget.VoxelPalette)
    (chunkX chunkZ : Nat) (yNat surfaceY maxY : Nat) : Afferent.Widget.VoxelColor :=
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
      let t := Linalg.Float.clamp (yNat.toFloat / denom) 0.0 1.0
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
        {
          r := Linalg.Float.min 1.0 (r + 0.15)
          g := Linalg.Float.min 1.0 (g + 0.15)
          b := Linalg.Float.min 1.0 (b + 0.15)
          a := 1.0
        }
      else
        { r := r * 0.72, g := g * 0.72, b := b * 0.72, a := 1.0 }

private def colorToByte (x : Float) : Nat :=
  let clamped := Linalg.Float.clamp x 0.0 1.0
  Nat.min 255 ((clamped * 255.0 + 0.5).floor.toUInt64.toNat)

private def encodeColor (color : Afferent.Widget.VoxelColor) : Nat :=
  let r := colorToByte color.r
  let g := colorToByte color.g
  let b := colorToByte color.b
  r + g * 256 + b * 65536

private def decodeColor (code : Nat) : Afferent.Widget.VoxelColor :=
  let r := code % 256
  let g := (code / 256) % 256
  let b := (code / 65536) % 256
  {
    r := r.toFloat / 255.0
    g := g.toFloat / 255.0
    b := b.toFloat / 255.0
    a := 1.0
  }

private inductive TerrainVoxel where
  | air
  | solid (colorId : Nat)
  deriving Repr, Inhabited, BEq

instance : Linalg.Voxel.VoxelType TerrainVoxel where
  isSolid
    | .air => false
    | .solid _ => true
  sameKind
    | .solid a, .solid b => a == b
    | .air, .air => true
    | _, _ => false

private def terrainVoxelColor (voxel : TerrainVoxel) : Afferent.Widget.VoxelColor :=
  match voxel with
  | .air => { r := 0.0, g := 0.0, b := 0.0, a := 0.0 }
  | .solid colorId => decodeColor colorId

private def pushQuad (vertices : Array Float) (indices : Array UInt32)
    (baseVertex : Nat) (xOffset zOffset : Float)
    (quad : Linalg.Voxel.Quad TerrainVoxel) : Array Float × Array UInt32 := Id.run do
  let mut verts := vertices
  let (nx, ny, nz) := quad.normal
  let color := terrainVoxelColor quad.voxel
  for (x, y, z) in quad.corners do
    verts := verts.push (x + xOffset)
    verts := verts.push y
    verts := verts.push (z + zOffset)
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

def voxelWorldSceneConfig (params : VoxelWorldParams) : Afferent.Widget.VoxelSceneConfig :=
  if params.fogEnabled then
    {
      fovY := Linalg.Float.pi / 3.0
      nearPlane := 0.1
      farPlane := 600.0
      lightDir := #[0.45, 0.85, 0.35]
      ambient := 0.45
      showMesh := params.showMesh
      fogColor := #[0.06, 0.08, 0.12]
      fogStart := 45.0
      fogEnd := 160.0
    }
  else
    {
      fovY := Linalg.Float.pi / 3.0
      nearPlane := 0.1
      farPlane := 600.0
      lightDir := #[0.45, 0.85, 0.35]
      ambient := 0.45
      showMesh := params.showMesh
      fogColor := #[0.06, 0.08, 0.12]
      fogStart := 0.0
      fogEnd := 0.0
    }

def buildVoxelWorldMesh (params : VoxelWorldParams) : Afferent.Widget.VoxelMesh := Id.run do
  let safeChunkSize := 16
  let safeChunkHeight := Nat.max 1 params.chunkHeight
  let chunkCount := params.chunkRadius * 2 + 1
  let worldSpan := chunkCount * safeChunkSize
  let minX : Int := -(Int.ofNat (params.chunkRadius * safeChunkSize))
  let minZ : Int := minX
  let maxYNat := safeChunkHeight - 1
  let terrace := Nat.max 1 params.terraceStep

  let heightAt : Int → Int → Nat := fun x z =>
    let xf := intToFloat x * params.frequency
    let zf := intToFloat z * params.frequency
    let wave := (Float.sin xf + Float.cos zf + Float.sin (xf * 0.7 + zf * 1.1)) / 3.0
    let normalized := Linalg.Float.clamp ((wave + 1.0) * 0.5) 0.0 1.0
    let rawHeight := params.baseHeight.toFloat + normalized * params.heightRange.toFloat
    let base := rawHeight.floor.toUInt64.toNat
    let terraced := if terrace <= 1 then base else (base / terrace) * terrace
    Nat.min maxYNat terraced

  let sampled : Linalg.Voxel.SampledChunk TerrainVoxel := {
    sizeX := worldSpan
    sizeY := safeChunkHeight
    sizeZ := worldSpan
    sample := fun lx ly lz =>
      let wx := minX + lx
      let wz := minZ + lz
      let yNat := ly.toNat
      let surface := heightAt wx wz
      if yNat <= surface then
        let relX := lx.toNat
        let relZ := lz.toNat
        let chunkX := relX / safeChunkSize
        let chunkZ := relZ / safeChunkSize
        let baseColor := paletteColor params.palette chunkX chunkZ yNat surface maxYNat
        let color :=
          if params.showChunkBoundaries && yNat + 1 >= surface then
            let localX := relX % safeChunkSize
            let localZ := relZ % safeChunkSize
            let onBoundary :=
              localX == 0 || localZ == 0 ||
              localX + 1 == safeChunkSize || localZ + 1 == safeChunkSize
            if onBoundary then
              {
                baseColor with
                r := baseColor.r * 0.55
                g := baseColor.g * 0.55
                b := baseColor.b * 0.55
              }
            else
              baseColor
          else
            baseColor
        TerrainVoxel.solid (encodeColor color)
      else
        .air
  }

  let surface := Linalg.Voxel.mesh params.mesher sampled
  let mut vertices : Array Float := #[]
  let mut indices : Array UInt32 := #[]
  let mut vertexCount : Nat := 0
  let xOffset := intToFloat minX
  let zOffset := intToFloat minZ

  for quad in surface.quads do
    let (verts', inds') := pushQuad vertices indices vertexCount xOffset zOffset quad
    vertices := verts'
    indices := inds'
    vertexCount := vertexCount + 4

  return { vertices, indices }

def voxelWorldWidget (name : ComponentId) (mesh : Afferent.Widget.VoxelMesh)
    (camera : FPSCamera) (params : VoxelWorldParams) : WidgetBuilder := do
  Afferent.Widget.namedVoxelWorldWidget name mesh camera (voxelWorldSceneConfig params) {
    flexItem := some (Trellis.FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
    backgroundColor := some (Color.rgba 0.05 0.06 0.08 1.0)
  }

end Demos
