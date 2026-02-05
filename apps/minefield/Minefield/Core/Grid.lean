/-
  Minefield.Core.Grid
  Minefield grid representation
-/
import Minefield.Core.Types

namespace Minefield.Core

/-- The minefield grid is a 2D array of cells -/
structure Grid where
  cells : Array (Array Cell)
  width : Nat
  height : Nat
  deriving Repr, Inhabited

/-- Create an empty row of cells -/
def emptyRow (width : Nat) : Array Cell :=
  Array.range width |>.map fun _ => default

/-- Create an empty grid with the given dimensions -/
def Grid.empty (width height : Nat) : Grid :=
  let cells := Array.range height |>.map fun _ => emptyRow width
  { cells, width, height }

/-- Create a grid from a difficulty preset -/
def Grid.fromDifficulty (d : Difficulty) : Grid :=
  Grid.empty d.width d.height

/-- Check if a position is within bounds -/
def Grid.inBounds (g : Grid) (x y : Nat) : Bool :=
  x < g.width && y < g.height

/-- Check if a point is within bounds -/
def Grid.pointInBounds (g : Grid) (p : Point) : Bool :=
  g.inBounds p.x p.y

/-- Get the cell at a position (returns default if out of bounds) -/
def Grid.get (g : Grid) (x y : Nat) : Cell :=
  if h1 : y < g.cells.size then
    let row := g.cells[y]
    if h2 : x < row.size then row[x] else default
  else default

/-- Get the cell at a point -/
def Grid.getPoint (g : Grid) (p : Point) : Cell :=
  g.get p.x p.y

/-- Set a cell at a position -/
def Grid.set (g : Grid) (x y : Nat) (c : Cell) : Grid :=
  if h1 : y < g.cells.size then
    let row := g.cells[y]
    if h2 : x < row.size then
      { g with cells := g.cells.setIfInBounds y (row.setIfInBounds x c) }
    else g
  else g

/-- Set a cell at a point -/
def Grid.setPoint (g : Grid) (p : Point) (c : Cell) : Grid :=
  g.set p.x p.y c

/-- Modify a cell at a position with a function -/
def Grid.modify (g : Grid) (x y : Nat) (f : Cell → Cell) : Grid :=
  g.set x y (f (g.get x y))

/-- Modify a cell at a point with a function -/
def Grid.modifyPoint (g : Grid) (p : Point) (f : Cell → Cell) : Grid :=
  g.modify p.x p.y f

/-- Get all 8 neighboring positions (filtered to in-bounds) -/
def Grid.neighbors (g : Grid) (x y : Nat) : List Point :=
  let offsets : List (Int × Int) := [
    (-1, -1), (0, -1), (1, -1),
    (-1,  0),          (1,  0),
    (-1,  1), (0,  1), (1,  1)
  ]
  offsets.filterMap fun (dx, dy) =>
    let nx := (x : Int) + dx
    let ny := (y : Int) + dy
    if nx >= 0 && ny >= 0 then
      let nx' := nx.toNat
      let ny' := ny.toNat
      if g.inBounds nx' ny' then some ⟨nx', ny'⟩ else none
    else none

/-- Get neighbors of a point -/
def Grid.neighborsPoint (g : Grid) (p : Point) : List Point :=
  g.neighbors p.x p.y

/-- Count how many cells satisfy a predicate -/
def Grid.count (g : Grid) (pred : Cell → Bool) : Nat :=
  g.cells.foldl (fun acc row =>
    acc + row.foldl (fun acc2 cell => if pred cell then acc2 + 1 else acc2) 0
  ) 0

/-- Count revealed cells -/
def Grid.revealedCount (g : Grid) : Nat :=
  g.count Cell.isRevealed

/-- Count flagged cells -/
def Grid.flagCount (g : Grid) : Nat :=
  g.count Cell.isFlagged

/-- Count mines -/
def Grid.mineCount (g : Grid) : Nat :=
  g.count (·.hasMine)

/-- Get total number of cells -/
def Grid.totalCells (g : Grid) : Nat :=
  g.width * g.height

/-- Get all cell positions as a list -/
def Grid.allPositions (g : Grid) : List Point :=
  List.range g.height |>.flatMap fun y =>
    List.range g.width |>.map fun x => ⟨x, y⟩

/-- Iterate over all cells with their positions -/
def Grid.forEachM [Monad m] (g : Grid) (f : Point → Cell → m Unit) : m Unit := do
  for y in List.range g.height do
    for x in List.range g.width do
      f ⟨x, y⟩ (g.get x y)

end Minefield.Core
