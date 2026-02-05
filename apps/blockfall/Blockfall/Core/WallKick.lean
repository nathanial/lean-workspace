/-
  Blockfall.Core.WallKick
  Wall kick offset tables for rotation
-/
import Blockfall.Core.Types
import Blockfall.Core.Piece
import Blockfall.Core.Board
import Blockfall.Core.Collision

namespace Blockfall.Core

/-- Wall kick offsets for J, L, S, T, Z pieces (SRS simplified) -/
def standardKicks (fromRot toRot : Nat) : List Point :=
  match fromRot % 4, toRot % 4 with
  | 0, 1 => [⟨0, 0⟩, ⟨-1, 0⟩, ⟨-1, -1⟩, ⟨0, 2⟩, ⟨-1, 2⟩]
  | 1, 0 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨1, 1⟩, ⟨0, -2⟩, ⟨1, -2⟩]
  | 1, 2 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨1, 1⟩, ⟨0, -2⟩, ⟨1, -2⟩]
  | 2, 1 => [⟨0, 0⟩, ⟨-1, 0⟩, ⟨-1, -1⟩, ⟨0, 2⟩, ⟨-1, 2⟩]
  | 2, 3 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨1, -1⟩, ⟨0, 2⟩, ⟨1, 2⟩]
  | 3, 2 => [⟨0, 0⟩, ⟨-1, 0⟩, ⟨-1, 1⟩, ⟨0, -2⟩, ⟨-1, -2⟩]
  | 3, 0 => [⟨0, 0⟩, ⟨-1, 0⟩, ⟨-1, 1⟩, ⟨0, -2⟩, ⟨-1, -2⟩]
  | 0, 3 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨1, -1⟩, ⟨0, 2⟩, ⟨1, 2⟩]
  | _, _ => [⟨0, 0⟩]  -- Same rotation (shouldn't happen)

/-- Wall kick offsets for I piece (different from standard) -/
def iKicks (fromRot toRot : Nat) : List Point :=
  match fromRot % 4, toRot % 4 with
  | 0, 1 => [⟨0, 0⟩, ⟨-2, 0⟩, ⟨1, 0⟩, ⟨-2, 1⟩, ⟨1, -2⟩]
  | 1, 0 => [⟨0, 0⟩, ⟨2, 0⟩, ⟨-1, 0⟩, ⟨2, -1⟩, ⟨-1, 2⟩]
  | 1, 2 => [⟨0, 0⟩, ⟨-1, 0⟩, ⟨2, 0⟩, ⟨-1, -2⟩, ⟨2, 1⟩]
  | 2, 1 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨-2, 0⟩, ⟨1, 2⟩, ⟨-2, -1⟩]
  | 2, 3 => [⟨0, 0⟩, ⟨2, 0⟩, ⟨-1, 0⟩, ⟨2, -1⟩, ⟨-1, 2⟩]
  | 3, 2 => [⟨0, 0⟩, ⟨-2, 0⟩, ⟨1, 0⟩, ⟨-2, 1⟩, ⟨1, -2⟩]
  | 3, 0 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨-2, 0⟩, ⟨1, 2⟩, ⟨-2, -1⟩]
  | 0, 3 => [⟨0, 0⟩, ⟨-1, 0⟩, ⟨2, 0⟩, ⟨-1, -2⟩, ⟨2, 1⟩]
  | _, _ => [⟨0, 0⟩]

/-- Get wall kick offsets for a piece rotation -/
def getKicks (pieceType : PieceType) (fromRot toRot : Nat) : List Point :=
  match pieceType with
  | .I => iKicks fromRot toRot
  | .O => [⟨0, 0⟩]  -- O piece doesn't need kicks
  | _ => standardKicks fromRot toRot

/-- Try to rotate a piece with wall kicks, returning new position if successful -/
def tryRotate (board : Board) (piece : Piece) (pos : Point) (clockwise : Bool := true) : Option (Piece × Point) :=
  let newPiece := if clockwise then piece.rotateCW else piece.rotateCCW
  let kicks := getKicks piece.pieceType piece.rotation newPiece.rotation
  -- Try each kick offset
  kicks.findSome? fun kick =>
    let newPos := pos + kick
    if collides board newPiece newPos then none
    else some (newPiece, newPos)

end Blockfall.Core
