/-
  Twenty48 Tests
-/
import Crucible
import Twenty48

namespace Twenty48.Tests

open Crucible
open Twenty48.Core
open Twenty48.Game

testSuite "Twenty48 Tests"

-- Grid Tests

test "Empty grid has 16 empty cells" := do
  let grid := Grid.empty
  let emptyCells := grid.emptyCells
  emptyCells.length ≡ 16

test "Grid set and get" := do
  let grid := Grid.empty
  let grid' := grid.set 2 3 (some 5)
  grid'.get 2 3 ≡ some 5
  grid'.get 0 0 ≡ none

test "Grid is full when no empty cells" := do
  let mut grid := Grid.empty
  for y in List.range gridSize do
    for x in List.range gridSize do
      grid := grid.set x y (some 1)
  ensure grid.isFull "Full grid should be full"
  ensure (grid.emptyCells.isEmpty) "Full grid should have no empty cells"

test "Grid equality" := do
  let g1 := Grid.empty.set 1 1 (some 2)
  let g2 := Grid.empty.set 1 1 (some 2)
  let g3 := Grid.empty.set 1 1 (some 3)
  ensure (g1 == g2) "Same grids should be equal"
  ensure (!(g1 == g3)) "Different grids should not be equal"

-- Slide Tests

test "Slide line merges adjacent equals" := do
  let line : Array Tile := #[some 1, some 1, none, none]
  let (result, score, _) := slideLine line
  result[0]! ≡ some 2  -- 2+2=4 (exponent 1+1=2)
  result[1]! ≡ none
  score ≡ 4  -- Score is the merged value

test "Slide line moves tiles left" := do
  let line : Array Tile := #[none, none, some 1, some 2]
  let (result, score, _) := slideLine line
  result[0]! ≡ some 1
  result[1]! ≡ some 2
  result[2]! ≡ none
  result[3]! ≡ none
  score ≡ 0  -- No merges

test "Slide doesn't merge already-merged tiles" := do
  -- [2, 2, 2, 2] should become [4, 4, _, _], not [8, _, _, _]
  let line : Array Tile := #[some 1, some 1, some 1, some 1]
  let (result, score, _) := slideLine line
  result[0]! ≡ some 2  -- First merge: 2+2=4
  result[1]! ≡ some 2  -- Second merge: 2+2=4
  result[2]! ≡ none
  result[3]! ≡ none
  score ≡ 8  -- 4 + 4

test "Slide grid left" := do
  let mut grid := Grid.empty
  grid := grid.set 3 0 (some 1)  -- 2 at rightmost
  grid := grid.set 2 0 (some 1)  -- 2 next to it

  let (result, score, _, changed) := grid.slide .left
  ensure changed "Grid should change"
  result.get 0 0 ≡ some 2  -- Merged: 4
  result.get 1 0 ≡ none
  score ≡ 4

test "No change when slide impossible" := do
  let mut grid := Grid.empty
  grid := grid.set 0 0 (some 1)
  grid := grid.set 1 0 (some 2)

  let (_, _, _, changed) := grid.slide .left
  ensure (!changed) "Grid should not change when tiles can't move"

test "Grid canMove detects available moves" := do
  let grid := Grid.empty.set 0 0 (some 1)
  ensure grid.canMove "Grid with space should allow moves"

test "Grid canMove detects no moves on full grid without merges" := do
  let mut grid := Grid.empty
  -- Fill with alternating 2 and 4 (no adjacent equals)
  for y in List.range gridSize do
    for x in List.range gridSize do
      let val := if (x + y) % 2 == 0 then 1 else 2
      grid := grid.set x y (some val)
  ensure (!grid.canMove) "Full grid without merges should not allow moves"

-- Game Logic Tests

test "Spawn tile places tile on grid" := do
  let state := GameState.new 12345
  let spawned := spawnTile state
  let emptyCells := spawned.grid.emptyCells
  emptyCells.length ≡ 15  -- One tile placed

test "Init game spawns two tiles" := do
  let state := initGame 12345
  let emptyCells := state.grid.emptyCells
  emptyCells.length ≡ 14  -- Two tiles placed

test "Move updates score" := do
  let mut grid := Grid.empty
  grid := grid.set 0 0 (some 1)
  grid := grid.set 1 0 (some 1)

  let state := { GameState.new 12345 with grid := grid }
  let moved := move state .left
  ensure (moved.score >= 4) "Score should increase after merge"

test "Undo restores previous state" := do
  let mut grid := Grid.empty
  grid := grid.set 0 0 (some 1)
  grid := grid.set 1 0 (some 1)

  let state := { GameState.new 12345 with grid := grid }
  let moved := move state .left
  let undone := undo moved

  undone.grid.get 0 0 ≡ some 1
  undone.grid.get 1 0 ≡ some 1
  undone.score ≡ 0

test "Win detection at 2048" := do
  let grid := Grid.empty.set 0 0 (some 11)  -- 2^11 = 2048
  ensure (hasWinningTile grid) "Should detect 2048 tile"

test "No win before 2048" := do
  let grid := Grid.empty.set 0 0 (some 10)  -- 2^10 = 1024
  ensure (!hasWinningTile grid) "Should not detect win at 1024"

test "Tile value calculation" := do
  tileValue none ≡ 0
  tileValue (some 1) ≡ 2
  tileValue (some 2) ≡ 4
  tileValue (some 10) ≡ 1024
  tileValue (some 11) ≡ 2048

end Twenty48.Tests

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║         Twenty48 Test Suite            ║"
  IO.println "╚════════════════════════════════════════╝"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result == 0 then
    IO.println "✓ All tests passed!"
  else
    IO.println "✗ Some tests failed"

  return result
