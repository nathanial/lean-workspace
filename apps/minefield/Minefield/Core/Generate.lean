/-
  Minefield.Core.Generate
  Mine placement and adjacent mine counting
-/
import Minefield.Core.Types
import Minefield.Core.Grid
import Minefield.Core.Random

namespace Minefield.Core

/-- Get the "safe zone" positions for opening first click -/
def safeZone (g : Grid) (clickPos : Point) : List Point :=
  -- Include the click position and all its neighbors
  clickPos :: g.neighborsPoint clickPos

/-- Get all positions that can have mines (excluding safe zone) -/
def mineablePositions (g : Grid) (clickPos : Point) : List Point :=
  let safe := safeZone g clickPos
  g.allPositions.filter (fun p => !safe.contains p)

/-- Place mines on the grid at the given positions -/
def placeMines (g : Grid) (positions : List Point) : Grid :=
  positions.foldl (fun grid pos =>
    grid.modifyPoint pos (fun c => { c with hasMine := true })
  ) g

/-- Count adjacent mines for a single cell -/
def countAdjacentMines (g : Grid) (x y : Nat) : Nat :=
  (g.neighbors x y).foldl (fun count neighbor =>
    if (g.getPoint neighbor).hasMine then count + 1 else count
  ) 0

/-- Compute adjacent mine counts for all cells -/
def computeAdjacentCounts (g : Grid) : Grid :=
  List.range g.height |>.foldl (fun grid1 y =>
    List.range g.width |>.foldl (fun grid2 x =>
      let count := countAdjacentMines grid2 x y
      grid2.modify x y (fun c => { c with adjacentMines := count })
    ) grid1
  ) g

/-- Generate mines on grid with safe first click guarantee.
    Returns the grid with mines placed and adjacent counts computed. -/
def generateMines (g : Grid) (clickPos : Point) (mineCount : Nat) (rng : RNG) : Grid × RNG :=
  let available := mineablePositions g clickPos
  -- Don't place more mines than available positions
  let actualMineCount := min mineCount available.length
  let (minePositions, newRng) := pickN rng available actualMineCount
  let gridWithMines := placeMines g minePositions
  let finalGrid := computeAdjacentCounts gridWithMines
  (finalGrid, newRng)

end Minefield.Core
