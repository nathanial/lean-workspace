/-
  Twenty48.Core.Grid
  4x4 grid structure and operations
-/
import Twenty48.Core.Types

namespace Twenty48.Core

/-- The game grid is a 4x4 array of tiles -/
structure Grid where
  cells : Array (Array Tile)
  deriving Repr

instance : Inhabited Grid where
  default := { cells := Array.range gridSize |>.map fun _ =>
    Array.range gridSize |>.map fun _ => none }

/-- Create an empty grid -/
def Grid.empty : Grid :=
  { cells := Array.range gridSize |>.map fun _ =>
      Array.range gridSize |>.map fun _ => none }

/-- Get the tile at a position -/
def Grid.get (g : Grid) (x y : Nat) : Tile :=
  if h1 : y < g.cells.size then
    let row := g.cells[y]
    if h2 : x < row.size then row[x] else none
  else none

/-- Set the tile at a position -/
def Grid.set (g : Grid) (x y : Nat) (t : Tile) : Grid :=
  if h1 : y < g.cells.size then
    let row := g.cells[y]
    if h2 : x < row.size then
      { cells := g.cells.setIfInBounds y (row.setIfInBounds x t) }
    else g
  else g

/-- Get a row as an array -/
def Grid.getRow (g : Grid) (y : Nat) : Array Tile :=
  if h : y < g.cells.size then g.cells[y] else #[]

/-- Get a column as an array -/
def Grid.getCol (g : Grid) (x : Nat) : Array Tile :=
  g.cells.map fun row =>
    if h : x < row.size then row[x] else none

/-- Set a row -/
def Grid.setRow (g : Grid) (y : Nat) (row : Array Tile) : Grid :=
  if _h : y < g.cells.size then
    { cells := g.cells.setIfInBounds y row }
  else g

/-- Set a column -/
def Grid.setCol (g : Grid) (x : Nat) (col : Array Tile) : Grid := Id.run do
  let mut result := g
  for y in List.range gridSize do
    if h : y < col.size then
      result := result.set x y col[y]
  result

/-- Get all empty cell positions -/
def Grid.emptyCells (g : Grid) : List Point := Id.run do
  let mut result : List Point := []
  for y in List.range gridSize do
    for x in List.range gridSize do
      if g.get x y == none then
        result := ⟨x, y⟩ :: result
  result.reverse

/-- Check if the grid is full -/
def Grid.isFull (g : Grid) : Bool :=
  g.emptyCells.isEmpty

/-- Get the maximum tile value (exponent) on the grid -/
def Grid.maxTile (g : Grid) : Nat := Id.run do
  let mut maxVal := 0
  for y in List.range gridSize do
    for x in List.range gridSize do
      match g.get x y with
      | some n => if n > maxVal then maxVal := n
      | none => pure ()
  maxVal

/-- Check if grids are equal -/
def Grid.beq (g1 g2 : Grid) : Bool :=
  g1.cells == g2.cells

instance : BEq Grid where
  beq := Grid.beq

end Twenty48.Core
