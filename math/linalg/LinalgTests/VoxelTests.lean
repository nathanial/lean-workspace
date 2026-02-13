/-
  Tests for voxel chunk abstractions and meshers.
-/

import Linalg
import Crucible

namespace LinalgTests.VoxelTests

open Crucible
open Linalg
open Linalg.Voxel

inductive TestVoxel where
  | air
  | stone
  | dirt
  deriving Repr, Inhabited, BEq

instance : VoxelType TestVoxel where
  isSolid
    | .air => false
    | _ => true
  sameKind := (· == ·)

private def solidChunk (sx sy sz : Nat) (voxel : TestVoxel := .stone) : DenseChunk TestVoxel :=
  DenseChunk.filled sx sy sz voxel

testSuite "Voxel Mesher"

test "single voxel has 6 visible faces for both meshers" := do
  let mut chunk := DenseChunk.filled 1 1 1 TestVoxel.air
  chunk := chunk.set 0 0 0 .stone
  let culled := mesh .culled chunk
  let greedy := mesh .greedy chunk
  ensure (culled.quadCount == 6) "culled should emit 6 quads"
  ensure (greedy.quadCount == 6) "greedy should emit 6 quads"
  ensure (culled.visibleCellFaceCount == 6) "culled should cover 6 unit faces"
  ensure (greedy.visibleCellFaceCount == 6) "greedy should cover 6 unit faces"

test "two adjacent equal voxels merge down to 6 quads with greedy" := do
  let chunk := solidChunk 2 1 1 .stone
  let culled := mesh .culled chunk
  let greedy := mesh .greedy chunk
  ensure (culled.quadCount == 10) "culled should emit 10 quads"
  ensure (greedy.quadCount == 6) "greedy should merge to 6 quads"
  ensure (greedy.visibleCellFaceCount == culled.visibleCellFaceCount)
    "greedy should preserve covered face area"

test "greedy does not merge across different voxel kinds" := do
  let mut chunk := DenseChunk.filled 2 1 1 TestVoxel.air
  chunk := chunk.set 0 0 0 .stone
  chunk := chunk.set 1 0 0 .dirt
  let greedy := mesh .greedy chunk
  ensure (greedy.quadCount == 10) "different materials should stay split"

test "2x2x2 solid cube becomes 6 large quads with greedy" := do
  let chunk := solidChunk 2 2 2 .stone
  let culled := mesh .culled chunk
  let greedy := mesh .greedy chunk
  ensure (culled.quadCount == 24) "culled should emit one quad per visible cell face"
  ensure (greedy.quadCount == 6) "greedy should emit one quad per cube side"
  ensure (greedy.visibleCellFaceCount == 24) "greedy should still cover full surface area"

test "sampled chunk works with mesher dispatch" := do
  let sampled : SampledChunk TestVoxel := {
    sizeX := 8
    sizeY := 6
    sizeZ := 8
    sample := fun x y z =>
      if y <= (x + z) / 4 then .stone else .air
  }
  let surface := mesh .greedy sampled
  ensure (surface.quadCount > 0) "sampled chunk should produce some quads"

end LinalgTests.VoxelTests
