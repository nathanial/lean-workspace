/-
  Blockfall.Core.Collision
  Collision detection for pieces and board
-/
import Blockfall.Core.Types
import Blockfall.Core.Piece
import Blockfall.Core.Board

namespace Blockfall.Core

/-- Check if a piece at a position collides with walls or locked pieces -/
def collides (board : Board) (piece : Piece) (pos : Point) : Bool :=
  let cells := piece.cellsAt pos
  cells.any fun cell =>
    -- Check bounds
    if cell.x < 0 || cell.x >= boardWidth then true
    else if cell.y >= boardHeight then true
    else if cell.y < 0 then false  -- Above board is OK
    else
      -- Check collision with locked pieces
      !board.isEmpty cell.x cell.y

/-- Check if a piece can move in a direction -/
def canMove (board : Board) (piece : Piece) (pos : Point) (dir : Direction) : Bool :=
  !collides board piece (pos + dir.toOffset)

/-- Lock a piece onto the board -/
def lockPiece (board : Board) (piece : Piece) (pos : Point) : Board := Id.run do
  let mut b := board
  for cell in piece.cellsAt pos do
    if cell.y >= 0 && cell.y < boardHeight && cell.x >= 0 && cell.x < boardWidth then
      b := b.set cell.x.toNat cell.y.toNat (some piece.color)
  b

/-- Calculate ghost piece Y position (where piece would land) -/
def ghostY (board : Board) (piece : Piece) (pos : Point) : Int := Id.run do
  let mut y := pos.y
  while !collides board piece ⟨pos.x, y + 1⟩ do
    y := y + 1
  y

/-- Check if game is over (piece spawns in collision) -/
def isGameOver (board : Board) (piece : Piece) : Bool :=
  collides board piece spawnPos

end Blockfall.Core
