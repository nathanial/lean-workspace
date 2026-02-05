/-
  Blockfall.Core.Piece
  Tetromino piece definitions with rotations
-/
import Blockfall.Core.Types

namespace Blockfall.Core

/-- A piece is defined by its type and current rotation state (0-3) -/
structure Piece where
  pieceType : PieceType
  rotation : Nat := 0
  deriving Repr, BEq, Inhabited

/-- Get the cell offsets for a piece type at a given rotation
    Coordinates are relative to the piece's pivot point.
    Each piece has 4 rotation states. -/
def PieceType.cells (t : PieceType) (rotation : Nat) : List Point :=
  let r := rotation % 4
  match t with
  | .I => match r with
    | 0 => [⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨3, 1⟩]  -- Horizontal
    | 1 => [⟨2, 0⟩, ⟨2, 1⟩, ⟨2, 2⟩, ⟨2, 3⟩]  -- Vertical
    | 2 => [⟨0, 2⟩, ⟨1, 2⟩, ⟨2, 2⟩, ⟨3, 2⟩]  -- Horizontal (shifted)
    | _ => [⟨1, 0⟩, ⟨1, 1⟩, ⟨1, 2⟩, ⟨1, 3⟩]  -- Vertical (shifted)
  | .O => -- Square doesn't change with rotation
    [⟨1, 0⟩, ⟨2, 0⟩, ⟨1, 1⟩, ⟨2, 1⟩]
  | .T => match r with
    | 0 => [⟨1, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩]  -- T pointing up
    | 1 => [⟨1, 0⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨1, 2⟩]  -- T pointing right
    | 2 => [⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨1, 2⟩]  -- T pointing down
    | _ => [⟨1, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩, ⟨1, 2⟩]  -- T pointing left
  | .S => match r with
    | 0 => [⟨1, 0⟩, ⟨2, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩]
    | 1 => [⟨1, 0⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨2, 2⟩]
    | 2 => [⟨1, 1⟩, ⟨2, 1⟩, ⟨0, 2⟩, ⟨1, 2⟩]
    | _ => [⟨0, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩, ⟨1, 2⟩]
  | .Z => match r with
    | 0 => [⟨0, 0⟩, ⟨1, 0⟩, ⟨1, 1⟩, ⟨2, 1⟩]
    | 1 => [⟨2, 0⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨1, 2⟩]
    | 2 => [⟨0, 1⟩, ⟨1, 1⟩, ⟨1, 2⟩, ⟨2, 2⟩]
    | _ => [⟨1, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩, ⟨0, 2⟩]
  | .J => match r with
    | 0 => [⟨0, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩]
    | 1 => [⟨1, 0⟩, ⟨2, 0⟩, ⟨1, 1⟩, ⟨1, 2⟩]
    | 2 => [⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨2, 2⟩]
    | _ => [⟨1, 0⟩, ⟨1, 1⟩, ⟨0, 2⟩, ⟨1, 2⟩]
  | .L => match r with
    | 0 => [⟨2, 0⟩, ⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩]
    | 1 => [⟨1, 0⟩, ⟨1, 1⟩, ⟨1, 2⟩, ⟨2, 2⟩]
    | 2 => [⟨0, 1⟩, ⟨1, 1⟩, ⟨2, 1⟩, ⟨0, 2⟩]
    | _ => [⟨0, 0⟩, ⟨1, 0⟩, ⟨1, 1⟩, ⟨1, 2⟩]

/-- Get the cells for a piece at its current rotation -/
def Piece.cells (p : Piece) : List Point :=
  p.pieceType.cells p.rotation

/-- Get the absolute positions of piece cells given a position -/
def Piece.cellsAt (p : Piece) (pos : Point) : List Point :=
  p.cells.map (· + pos)

/-- Get the color of a piece -/
def Piece.color (p : Piece) : Terminus.Color :=
  p.pieceType.color

/-- Rotate a piece clockwise -/
def Piece.rotateCW (p : Piece) : Piece :=
  { p with rotation := (p.rotation + 1) % 4 }

/-- Rotate a piece counter-clockwise -/
def Piece.rotateCCW (p : Piece) : Piece :=
  { p with rotation := (p.rotation + 3) % 4 }

/-- Create a piece from a type -/
def Piece.fromType (t : PieceType) : Piece :=
  { pieceType := t, rotation := 0 }

end Blockfall.Core
