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
  fogEnabled : Bool := true
  showChunkBoundaries : Bool := true
  deriving Repr, Inhabited, BEq

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

def voxelWorldRadiusToSlider (radius : Nat) : Float := natToSlider radius 0 2
def voxelWorldRadiusFromSlider (t : Float) : Nat := sliderToNat t 0 2

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

def voxelWorldToTerrainParams (params : VoxelWorldParams) : Afferent.Widget.ChunkedTerrainParams := {
  chunkRadius := params.chunkRadius
  chunkSize := 16
  chunkHeight := params.chunkHeight
  baseHeight := params.baseHeight
  heightRange := params.heightRange
  frequency := params.frequency
  terraceStep := params.terraceStep
  palette := params.palette
  showChunkBoundaries := params.showChunkBoundaries
}

def voxelWorldSceneConfig (params : VoxelWorldParams) : Afferent.Widget.VoxelSceneConfig :=
  if params.fogEnabled then
    {
      fovY := Linalg.Float.pi / 3.0
      nearPlane := 0.1
      farPlane := 600.0
      lightDir := #[0.45, 0.85, 0.35]
      ambient := 0.45
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
      fogColor := #[0.06, 0.08, 0.12]
      fogStart := 0.0
      fogEnd := 0.0
    }

def buildVoxelWorldMesh (params : VoxelWorldParams) : Afferent.Widget.VoxelMesh :=
  Afferent.Widget.generateChunkedTerrainMesh (voxelWorldToTerrainParams params)

def voxelWorldWidget (name : ComponentId) (mesh : Afferent.Widget.VoxelMesh)
    (camera : FPSCamera) (params : VoxelWorldParams) : WidgetBuilder := do
  Afferent.Widget.namedVoxelWorldWidget name mesh camera (voxelWorldSceneConfig params) {
    flexItem := some (Trellis.FlexItem.growing 1)
    width := .percent 1.0
    height := .percent 1.0
    backgroundColor := some (Color.rgba 0.05 0.06 0.08 1.0)
  }

end Demos
