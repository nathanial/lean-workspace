/-
  Blockfall.Core.Board
  Game board representation
-/
import Blockfall.Core.Types
import Terminus

namespace Blockfall.Core

/-- A cell on the board - either empty or filled with a color -/
abbrev Cell := Option Terminus.Color

/-- The game board is a 2D grid of cells -/
structure Board where
  cells : Array (Array Cell)
  deriving Repr, Inhabited

/-- Create an empty row -/
def emptyRow : Array Cell :=
  Array.range boardWidth |>.map fun _ => none

/-- Create an empty board -/
def Board.empty : Board :=
  { cells := Array.range boardHeight |>.map fun _ => emptyRow }

/-- Get the cell at a position (returns none if out of bounds) -/
def Board.get (b : Board) (x y : Nat) : Cell :=
  if h1 : y < b.cells.size then
    let row := b.cells[y]
    if h2 : x < row.size then row[x] else none
  else none

/-- Check if a position is within bounds -/
def Board.inBounds (x y : Int) : Bool :=
  x >= 0 && x < boardWidth && y >= 0 && y < boardHeight

/-- Check if a position is empty (or out of bounds on top) -/
def Board.isEmpty (b : Board) (x y : Int) : Bool :=
  if y < 0 then true  -- Above board is valid
  else if x < 0 || x >= boardWidth || y >= boardHeight then false
  else b.get x.toNat y.toNat == none

/-- Set a cell at a position -/
def Board.set (b : Board) (x y : Nat) (c : Cell) : Board :=
  if h1 : y < b.cells.size then
    let row := b.cells[y]
    if h2 : x < row.size then
      { cells := b.cells.setIfInBounds y (row.setIfInBounds x c) }
    else b
  else b

/-- Check if a row is complete (all filled) -/
def Board.isRowComplete (b : Board) (y : Nat) : Bool :=
  if h : y < b.cells.size then
    b.cells[y].all Option.isSome
  else false

/-- Get all complete row indices -/
def Board.completeRows (b : Board) : List Nat :=
  List.range boardHeight |>.filter b.isRowComplete

/-- Remove a row and shift everything above down -/
def Board.removeRow (b : Board) (y : Nat) : Board :=
  if y >= b.cells.size then b
  else
    -- Remove row at y and add empty row at top
    let upper := b.cells.extract 0 y
    let lower := b.cells.extract (y + 1) b.cells.size
    { cells := #[emptyRow] ++ upper ++ lower }

/-- Clear all complete rows and return count -/
def Board.clearLines (b : Board) : Board × Nat := Id.run do
  let mut board := b
  let mut cleared := 0
  -- Check from top to bottom so row shifts don't skip rows
  -- After removing a row, stay at the same y since rows shifted down
  let mut y := 0
  while y < boardHeight do
    if board.isRowComplete y then
      board := board.removeRow y
      cleared := cleared + 1
      -- Don't increment y - check same position again since rows shifted
    else
      y := y + 1
  (board, cleared)

end Blockfall.Core
