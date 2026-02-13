/-
  Core voxel abstractions shared by chunk storage and meshers.
-/

import Linalg.Core

namespace Linalg.Voxel

/-- Faces of an axis-aligned voxel cube. -/
inductive Face where
  | top
  | bottom
  | north
  | south
  | east
  | west
  deriving Repr, Inhabited, BEq

/-- All voxel faces. -/
def allFaces : Array Face := #[
  .top, .bottom, .north, .south, .east, .west
]

/-- Unit normal for a voxel face. -/
def Face.normal (face : Face) : Float × Float × Float :=
  match face with
  | .top => (0.0, 1.0, 0.0)
  | .bottom => (0.0, -1.0, 0.0)
  | .north => (0.0, 0.0, 1.0)
  | .south => (0.0, 0.0, -1.0)
  | .east => (1.0, 0.0, 0.0)
  | .west => (-1.0, 0.0, 0.0)

/-- Neighbor offset for each face direction. -/
def Face.neighborOffset (face : Face) : Int × Int × Int :=
  match face with
  | .top => (0, 1, 0)
  | .bottom => (0, -1, 0)
  | .north => (0, 0, 1)
  | .south => (0, 0, -1)
  | .east => (1, 0, 0)
  | .west => (-1, 0, 0)

/-- Typeclass for voxel values. -/
class VoxelType (α : Type) where
  /-- Whether this voxel contributes to solid geometry. -/
  isSolid : α → Bool
  /-- Whether two solids can be merged by a greedy mesher. -/
  sameKind : α → α → Bool

/-- Typeclass for chunk-like voxel containers. -/
class VoxelChunk (χ : Type) (α : outParam Type) where
  /-- X dimension in voxels. -/
  sizeX : χ → Nat
  /-- Y dimension in voxels. -/
  sizeY : χ → Nat
  /-- Z dimension in voxels. -/
  sizeZ : χ → Nat
  /-- Voxel sampling in local chunk coordinates. -/
  voxelAt? : χ → Int → Int → Int → Option α

/-- Rectangular face in voxel space produced by meshers. -/
structure Quad (α : Type) where
  face : Face
  x : Int
  y : Int
  z : Int
  width : Nat := 1
  height : Nat := 1
  voxel : α
  deriving Repr, Inhabited

/-- Surface output from voxel meshing algorithms. -/
structure Surface (α : Type) where
  quads : Array (Quad α) := #[]
  deriving Repr, Inhabited

private def intToFloat (i : Int) : Float :=
  if i >= 0 then i.toNat.toFloat else -((-i).toNat.toFloat)

/-- Corner vertices for this quad in voxel-local coordinates. -/
def Quad.corners (q : Quad α) : Array (Float × Float × Float) :=
  let x := intToFloat q.x
  let y := intToFloat q.y
  let z := intToFloat q.z
  let w := q.width.toFloat
  let h := q.height.toFloat
  match q.face with
  | .top =>
      #[
        (x, y + 1.0, z),
        (x + w, y + 1.0, z),
        (x + w, y + 1.0, z + h),
        (x, y + 1.0, z + h)
      ]
  | .bottom =>
      #[
        (x, y, z + h),
        (x + w, y, z + h),
        (x + w, y, z),
        (x, y, z)
      ]
  | .north =>
      #[
        (x + w, y, z + 1.0),
        (x, y, z + 1.0),
        (x, y + h, z + 1.0),
        (x + w, y + h, z + 1.0)
      ]
  | .south =>
      #[
        (x, y, z),
        (x + w, y, z),
        (x + w, y + h, z),
        (x, y + h, z)
      ]
  | .east =>
      #[
        (x + 1.0, y, z),
        (x + 1.0, y, z + w),
        (x + 1.0, y + h, z + w),
        (x + 1.0, y + h, z)
      ]
  | .west =>
      #[
        (x, y, z + w),
        (x, y, z),
        (x, y + h, z),
        (x, y + h, z + w)
      ]

/-- Normal for this quad. -/
def Quad.normal (q : Quad α) : Float × Float × Float :=
  q.face.normal

/-- Total quad count in this surface. -/
def Surface.quadCount (surface : Surface α) : Nat :=
  surface.quads.size

/-- Triangle count (2 triangles per quad). -/
def Surface.triangleCount (surface : Surface α) : Nat :=
  surface.quads.size * 2

/-- Unit-face area represented by this surface. -/
def Surface.visibleCellFaceCount (surface : Surface α) : Nat :=
  surface.quads.foldl (fun acc q => acc + q.width * q.height) 0

/-- Safe voxel sampling helper. -/
def sample? [VoxelChunk χ α] (chunk : χ) (x y z : Int) : Option α :=
  VoxelChunk.voxelAt? chunk x y z

/-- Solid check helper for neighbor/visibility tests. -/
def isSolidAt [VoxelType α] [VoxelChunk χ α] (chunk : χ) (x y z : Int) : Bool :=
  match sample? chunk x y z with
  | some voxel => VoxelType.isSolid voxel
  | none => false

end Linalg.Voxel
