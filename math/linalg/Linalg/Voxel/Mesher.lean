/-
  Voxel meshing algorithms:
  - Culled (one quad per visible voxel face)
  - Greedy (merge adjacent coplanar visible faces of same voxel kind)
-/

import Linalg.Voxel.Core
import Linalg.Voxel.Chunk

namespace Linalg.Voxel

/-- Supported voxel meshing algorithms. -/
inductive MesherAlgorithm where
  | culled
  | greedy
  deriving Repr, Inhabited, BEq

/-- Basic culled mesher: emits one quad per visible face. -/
def meshCulled [VoxelType α] [VoxelChunk χ α] (chunk : χ) : Surface α := Id.run do
  let sx := VoxelChunk.sizeX chunk
  let sy := VoxelChunk.sizeY chunk
  let sz := VoxelChunk.sizeZ chunk
  let mut quads : Array (Quad α) := #[]

  for y in [:sy] do
    let yi := Int.ofNat y
    for z in [:sz] do
      let zi := Int.ofNat z
      for x in [:sx] do
        let xi := Int.ofNat x
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel then
              for face in allFaces do
                let (dx, dy, dz) := face.neighborOffset
                if !isSolidAt chunk (xi + dx) (yi + dy) (zi + dz) then
                  quads := quads.push {
                    face := face
                    x := xi
                    y := yi
                    z := zi
                    width := 1
                    height := 1
                    voxel := voxel
                  }
        | none => pure ()

  return { quads := quads }

private def maskIndex (width u v : Nat) : Nat :=
  v * width + u

private structure MaskRect (α : Type) where
  u : Nat
  v : Nat
  w : Nat
  h : Nat
  voxel : α

private def extractRectangles [VoxelType α]
    (mask : Array (Option α)) (width height : Nat) : Array (MaskRect α) := Id.run do
  let mut visited : Array Bool := Array.replicate (width * height) false
  let mut rects : Array (MaskRect α) := #[]

  for v in [:height] do
    for u in [:width] do
      let startIdx := maskIndex width u v
      if visited[startIdx]! then
        pure ()
      else
        match mask[startIdx]! with
        | none =>
            visited := visited.set! startIdx true
        | some voxel =>
            let mut rectW := 0
            let mut scanW := true
            while scanW && (u + rectW < width) do
              let idx := maskIndex width (u + rectW) v
              if visited[idx]! then
                scanW := false
              else
                match mask[idx]! with
                | some other =>
                    if VoxelType.sameKind voxel other then
                      rectW := rectW + 1
                    else
                      scanW := false
                | none =>
                    scanW := false

            let mut rectH := 1
            let mut scanH := true
            while scanH && (v + rectH < height) do
              let mut rowMatches := true
              for du in [:rectW] do
                let idx := maskIndex width (u + du) (v + rectH)
                if visited[idx]! then
                  rowMatches := false
                else
                  match mask[idx]! with
                  | some other =>
                      if !VoxelType.sameKind voxel other then
                        rowMatches := false
                  | none =>
                      rowMatches := false
              if rowMatches then
                rectH := rectH + 1
              else
                scanH := false

            for dv in [:rectH] do
              for du in [:rectW] do
                let idx := maskIndex width (u + du) (v + dv)
                visited := visited.set! idx true

            rects := rects.push {
              u := u
              v := v
              w := rectW
              h := rectH
              voxel := voxel
            }

  return rects

/-- Greedy mesher: merges coplanar adjacent visible faces of same kind. -/
def meshGreedy [VoxelType α] [VoxelChunk χ α] (chunk : χ) : Surface α := Id.run do
  let sx := VoxelChunk.sizeX chunk
  let sy := VoxelChunk.sizeY chunk
  let sz := VoxelChunk.sizeZ chunk
  let mut quads : Array (Quad α) := #[]

  -- Top faces (+Y): 2D masks over X/Z per Y slice.
  for y in [:sy] do
    let yi := Int.ofNat y
    let mut mask : Array (Option α) := Array.replicate (sx * sz) none
    for z in [:sz] do
      let zi := Int.ofNat z
      for x in [:sx] do
        let xi := Int.ofNat x
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel && !isSolidAt chunk xi (yi + 1) zi then
              mask := mask.set! (maskIndex sx x z) (some voxel)
        | none => pure ()
    for rect in extractRectangles mask sx sz do
      quads := quads.push {
        face := .top
        x := Int.ofNat rect.u
        y := yi
        z := Int.ofNat rect.v
        width := rect.w
        height := rect.h
        voxel := rect.voxel
      }

  -- Bottom faces (-Y): 2D masks over X/Z per Y slice.
  for y in [:sy] do
    let yi := Int.ofNat y
    let mut mask : Array (Option α) := Array.replicate (sx * sz) none
    for z in [:sz] do
      let zi := Int.ofNat z
      for x in [:sx] do
        let xi := Int.ofNat x
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel && !isSolidAt chunk xi (yi - 1) zi then
              mask := mask.set! (maskIndex sx x z) (some voxel)
        | none => pure ()
    for rect in extractRectangles mask sx sz do
      quads := quads.push {
        face := .bottom
        x := Int.ofNat rect.u
        y := yi
        z := Int.ofNat rect.v
        width := rect.w
        height := rect.h
        voxel := rect.voxel
      }

  -- North faces (+Z): 2D masks over X/Y per Z slice.
  for z in [:sz] do
    let zi := Int.ofNat z
    let mut mask : Array (Option α) := Array.replicate (sx * sy) none
    for y in [:sy] do
      let yi := Int.ofNat y
      for x in [:sx] do
        let xi := Int.ofNat x
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel && !isSolidAt chunk xi yi (zi + 1) then
              mask := mask.set! (maskIndex sx x y) (some voxel)
        | none => pure ()
    for rect in extractRectangles mask sx sy do
      quads := quads.push {
        face := .north
        x := Int.ofNat rect.u
        y := Int.ofNat rect.v
        z := zi
        width := rect.w
        height := rect.h
        voxel := rect.voxel
      }

  -- South faces (-Z): 2D masks over X/Y per Z slice.
  for z in [:sz] do
    let zi := Int.ofNat z
    let mut mask : Array (Option α) := Array.replicate (sx * sy) none
    for y in [:sy] do
      let yi := Int.ofNat y
      for x in [:sx] do
        let xi := Int.ofNat x
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel && !isSolidAt chunk xi yi (zi - 1) then
              mask := mask.set! (maskIndex sx x y) (some voxel)
        | none => pure ()
    for rect in extractRectangles mask sx sy do
      quads := quads.push {
        face := .south
        x := Int.ofNat rect.u
        y := Int.ofNat rect.v
        z := zi
        width := rect.w
        height := rect.h
        voxel := rect.voxel
      }

  -- East faces (+X): 2D masks over Z/Y per X slice.
  for x in [:sx] do
    let xi := Int.ofNat x
    let mut mask : Array (Option α) := Array.replicate (sz * sy) none
    for y in [:sy] do
      let yi := Int.ofNat y
      for z in [:sz] do
        let zi := Int.ofNat z
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel && !isSolidAt chunk (xi + 1) yi zi then
              mask := mask.set! (maskIndex sz z y) (some voxel)
        | none => pure ()
    for rect in extractRectangles mask sz sy do
      quads := quads.push {
        face := .east
        x := xi
        y := Int.ofNat rect.v
        z := Int.ofNat rect.u
        width := rect.w
        height := rect.h
        voxel := rect.voxel
      }

  -- West faces (-X): 2D masks over Z/Y per X slice.
  for x in [:sx] do
    let xi := Int.ofNat x
    let mut mask : Array (Option α) := Array.replicate (sz * sy) none
    for y in [:sy] do
      let yi := Int.ofNat y
      for z in [:sz] do
        let zi := Int.ofNat z
        match sample? chunk xi yi zi with
        | some voxel =>
            if VoxelType.isSolid voxel && !isSolidAt chunk (xi - 1) yi zi then
              mask := mask.set! (maskIndex sz z y) (some voxel)
        | none => pure ()
    for rect in extractRectangles mask sz sy do
      quads := quads.push {
        face := .west
        x := xi
        y := Int.ofNat rect.v
        z := Int.ofNat rect.u
        width := rect.w
        height := rect.h
        voxel := rect.voxel
      }

  return { quads := quads }

/-- Mesh using the selected algorithm. -/
def mesh [VoxelType α] [VoxelChunk χ α]
    (algorithm : MesherAlgorithm) (chunk : χ) : Surface α :=
  match algorithm with
  | .culled => meshCulled chunk
  | .greedy => meshGreedy chunk

end Linalg.Voxel
