/-
  Reusable chunk containers for voxel data.
-/

import Linalg.Voxel.Core

namespace Linalg.Voxel

/-- Dense 3D chunk storage with flat array indexing. -/
structure DenseChunk (α : Type) where
  sizeX : Nat
  sizeY : Nat
  sizeZ : Nat
  voxels : Array α
  deriving Repr, Inhabited

namespace DenseChunk

/-- Expected voxel count for dimensions. -/
def expectedVoxelCount (sizeX sizeY sizeZ : Nat) : Nat :=
  sizeX * sizeY * sizeZ

/-- Total voxel count for this chunk's dimensions. -/
def voxelCount (chunk : DenseChunk α) : Nat :=
  expectedVoxelCount chunk.sizeX chunk.sizeY chunk.sizeZ

/-- Whether the underlying array matches declared dimensions. -/
def isWellFormed (chunk : DenseChunk α) : Bool :=
  chunk.voxels.size == chunk.voxelCount

/-- Flat array index for local coordinates. -/
private def index? (chunk : DenseChunk α) (x y z : Int) : Option Nat :=
  if x < 0 || y < 0 || z < 0 then
    none
  else
    let xn := x.toNat
    let yn := y.toNat
    let zn := z.toNat
    if xn < chunk.sizeX && yn < chunk.sizeY && zn < chunk.sizeZ then
      some (xn + zn * chunk.sizeX + yn * chunk.sizeX * chunk.sizeZ)
    else
      none

/-- Safe voxel lookup. -/
def get? (chunk : DenseChunk α) (x y z : Int) : Option α :=
  match index? chunk x y z with
  | some idx => chunk.voxels[idx]?
  | none => none

/-- Update a voxel if coordinates are in bounds. -/
def set (chunk : DenseChunk α) (x y z : Int) (voxel : α) : DenseChunk α :=
  match index? chunk x y z with
  | some idx =>
      if idx < chunk.voxels.size then
        { chunk with voxels := chunk.voxels.set! idx voxel }
      else
        chunk
  | none => chunk

/-- Build a chunk filled with a single value. -/
def filled (sizeX sizeY sizeZ : Nat) (voxel : α) : DenseChunk α :=
  { sizeX, sizeY, sizeZ, voxels := Array.replicate (expectedVoxelCount sizeX sizeY sizeZ) voxel }

/-- Build a chunk by sampling every local coordinate. -/
def fromFn (sizeX sizeY sizeZ : Nat) (f : Int → Int → Int → α) : DenseChunk α := Id.run do
  let mut voxels : Array α := Array.mkEmpty (expectedVoxelCount sizeX sizeY sizeZ)
  for y in [:sizeY] do
    for z in [:sizeZ] do
      for x in [:sizeX] do
        voxels := voxels.push (f (Int.ofNat x) (Int.ofNat y) (Int.ofNat z))
  return { sizeX, sizeY, sizeZ, voxels }

/-- Map voxels to another type while preserving dimensions. -/
def map (chunk : DenseChunk α) (f : α → β) : DenseChunk β :=
  { sizeX := chunk.sizeX, sizeY := chunk.sizeY, sizeZ := chunk.sizeZ, voxels := chunk.voxels.map f }

end DenseChunk

instance : VoxelChunk (DenseChunk α) α where
  sizeX := DenseChunk.sizeX
  sizeY := DenseChunk.sizeY
  sizeZ := DenseChunk.sizeZ
  voxelAt? := DenseChunk.get?

/-- Function-backed chunk useful for procedural generation. -/
structure SampledChunk (α : Type) where
  sizeX : Nat
  sizeY : Nat
  sizeZ : Nat
  sample : Int → Int → Int → α

namespace SampledChunk

/-- Safe lookup for sampled chunks. -/
def get? (chunk : SampledChunk α) (x y z : Int) : Option α :=
  if x < 0 || y < 0 || z < 0 then
    none
  else
    let xn := x.toNat
    let yn := y.toNat
    let zn := z.toNat
    if xn < chunk.sizeX && yn < chunk.sizeY && zn < chunk.sizeZ then
      some (chunk.sample x y z)
    else
      none

/-- Materialize a sampled chunk into dense storage. -/
def toDense (chunk : SampledChunk α) : DenseChunk α :=
  DenseChunk.fromFn chunk.sizeX chunk.sizeY chunk.sizeZ chunk.sample

end SampledChunk

instance : VoxelChunk (SampledChunk α) α where
  sizeX := SampledChunk.sizeX
  sizeY := SampledChunk.sizeY
  sizeZ := SampledChunk.sizeZ
  voxelAt? := SampledChunk.get?

end Linalg.Voxel
