/-
  Minefield Tests
-/
import Crucible
import Minefield

namespace Minefield.Tests

open Crucible
open Minefield.Core
open Minefield.Game

testSuite "Minefield Tests"

-- Core Types Tests

test "Difficulty presets" := do
  beginner.width ≡ 9
  beginner.height ≡ 9
  beginner.mines ≡ 10

  intermediate.width ≡ 16
  intermediate.height ≡ 16
  intermediate.mines ≡ 40

  expert.width ≡ 30
  expert.height ≡ 16
  expert.mines ≡ 99

test "Cell default state" := do
  let cell : Cell := default
  ensure cell.isHidden "Default cell should be hidden"
  ensure (!cell.hasMine) "Default cell should not have mine"
  cell.adjacentMines ≡ 0

test "Cell state checks" := do
  let hidden : Cell := { state := .hidden, hasMine := false, adjacentMines := 0 }
  let flagged : Cell := { state := .flagged, hasMine := true, adjacentMines := 0 }
  let revealed : Cell := { state := .revealed, hasMine := false, adjacentMines := 3 }

  ensure hidden.isHidden "Hidden cell should be hidden"
  ensure (!hidden.isFlagged) "Hidden cell should not be flagged"
  ensure (!hidden.isRevealed) "Hidden cell should not be revealed"

  ensure (!flagged.isHidden) "Flagged cell should not be hidden"
  ensure flagged.isFlagged "Flagged cell should be flagged"
  ensure (!flagged.isRevealed) "Flagged cell should not be revealed"

  ensure (!revealed.isHidden) "Revealed cell should not be hidden"
  ensure (!revealed.isFlagged) "Revealed cell should not be flagged"
  ensure revealed.isRevealed "Revealed cell should be revealed"

-- Grid Tests

test "Empty grid dimensions" := do
  let g := Grid.empty 9 9
  g.width ≡ 9
  g.height ≡ 9
  g.totalCells ≡ 81

test "Grid from difficulty" := do
  let g := Grid.fromDifficulty beginner
  g.width ≡ 9
  g.height ≡ 9

test "Grid get/set" := do
  let g := Grid.empty 5 5
  let cell : Cell := { state := .revealed, hasMine := true, adjacentMines := 2 }
  let g' := g.set 2 3 cell

  let retrieved := g'.get 2 3
  ensure retrieved.hasMine "Retrieved cell should have mine"
  retrieved.adjacentMines ≡ 2

test "Grid bounds checking" := do
  let g := Grid.empty 10 10
  ensure (g.inBounds 0 0) "Origin should be in bounds"
  ensure (g.inBounds 9 9) "Corner should be in bounds"
  ensure (!g.inBounds 10 5) "X=10 should be out of bounds"
  ensure (!g.inBounds 5 10) "Y=10 should be out of bounds"

test "Grid neighbors" := do
  let g := Grid.empty 5 5
  -- Center cell has 8 neighbors
  let centerNeighbors := g.neighbors 2 2
  centerNeighbors.length ≡ 8

  -- Corner cell has 3 neighbors
  let cornerNeighbors := g.neighbors 0 0
  cornerNeighbors.length ≡ 3

  -- Edge cell has 5 neighbors
  let edgeNeighbors := g.neighbors 0 2
  edgeNeighbors.length ≡ 5

test "Grid counting" := do
  let mut g := Grid.empty 3 3
  -- Set some cells as revealed
  g := g.modify 0 0 (fun c => { c with state := .revealed })
  g := g.modify 1 1 (fun c => { c with state := .revealed })
  g := g.modify 2 2 (fun c => { c with state := .flagged })

  g.revealedCount ≡ 2
  g.flagCount ≡ 1

-- RNG Tests

test "RNG produces different values" := do
  let rng := RNG.new 12345
  let (v1, rng') := rng.next
  let (v2, _) := rng'.next
  ensure (v1 != v2) "RNG should produce different values"

test "RNG bounded" := do
  let rng := RNG.new 12345
  let (v, _) := rng.nextBounded 10
  ensure (v < 10) "Bounded RNG should produce value < 10"

test "Shuffle preserves elements" := do
  let rng := RNG.new 42
  let original := [1, 2, 3, 4, 5]
  let (shuffled, _) := shuffleList rng original
  shuffled.length ≡ 5
  for x in original do
    ensure (shuffled.contains x) s!"Shuffled list should contain {x}"

-- Mine Generation Tests

test "Safe zone includes click and neighbors" := do
  let g := Grid.empty 5 5
  let safe := safeZone g ⟨2, 2⟩
  safe.length ≡ 9  -- Click position + 8 neighbors

test "Safe zone at corner" := do
  let g := Grid.empty 5 5
  let safe := safeZone g ⟨0, 0⟩
  safe.length ≡ 4  -- Click + 3 corner neighbors

test "Mineable positions excludes safe zone" := do
  let g := Grid.empty 5 5
  let mineable := mineablePositions g ⟨2, 2⟩
  mineable.length ≡ 16  -- 25 - 9

test "Mine generation places correct count" := do
  let g := Grid.empty 9 9
  let rng := RNG.new 12345
  let (generated, _) := generateMines g ⟨4, 4⟩ 10 rng
  generated.mineCount ≡ 10

test "First click is always safe" := do
  let g := Grid.empty 9 9
  let rng := RNG.new 12345
  let clickPos : Point := ⟨4, 4⟩
  let (generated, _) := generateMines g clickPos 10 rng

  -- Click position should not have mine
  let clickCell := generated.getPoint clickPos
  ensure (!clickCell.hasMine) "Click position should be safe"

  -- All neighbors should be safe too
  for neighbor in generated.neighborsPoint clickPos do
    let nCell := generated.getPoint neighbor
    ensure (!nCell.hasMine) s!"Neighbor at ({neighbor.x}, {neighbor.y}) should be safe"

test "Adjacent counts are correct" := do
  let mut g := Grid.empty 5 5
  -- Place a mine at (2, 2)
  g := g.modify 2 2 (fun c => { c with hasMine := true })
  let computed := computeAdjacentCounts g

  -- All 8 neighbors should have count 1
  for neighbor in g.neighbors 2 2 do
    let cell := computed.getPoint neighbor
    cell.adjacentMines ≡ 1

  -- Far corners should have count 0
  (computed.get 0 0).adjacentMines ≡ 0
  (computed.get 4 4).adjacentMines ≡ 0

-- Game State Tests

test "Initial game state" := do
  let state := GameState.new beginner 12345
  state.difficulty.name ≡ "Beginner"
  state.status ≡ .playing
  state.flagCount ≡ 0
  state.revealedCount ≡ 0
  ensure state.firstClick "Should be first click"
  ensure (!state.isGameOver) "Game should not be over"

test "Remaining mines calculation" := do
  let state := GameState.new beginner 12345
  state.remainingMines ≡ (10 : Int)
  let state' := { state with flagCount := 3 }
  state'.remainingMines ≡ (7 : Int)

test "Non-mine cells calculation" := do
  let state := GameState.new beginner 12345
  state.nonMineCells ≡ 71  -- 81 - 10

-- Game Logic Tests

test "Cursor movement wraps" := do
  let state := GameState.new beginner 12345
  let atTop := { state with cursor := ⟨4, 0⟩ }
  let movedUp := moveCursor atTop .up
  movedUp.cursor.y ≡ 8  -- Wrapped to bottom

  let atLeft := { state with cursor := ⟨0, 4⟩ }
  let movedLeft := moveCursor atLeft .left
  movedLeft.cursor.x ≡ 8  -- Wrapped to right

test "Flag toggle" := do
  -- Need to trigger first click to enable flagging
  let state := GameState.new beginner 12345
  let rng := RNG.new 54321
  let (gridWithMines, _) := generateMines state.grid ⟨4, 4⟩ 10 rng
  let state' := { state with
    grid := gridWithMines
    firstClick := false
    cursor := ⟨0, 0⟩
  }

  let flagged := toggleFlag state'
  flagged.flagCount ≡ 1
  ensure (flagged.grid.get 0 0).isFlagged "Cell should be flagged"

  let unflagged := toggleFlag flagged
  unflagged.flagCount ≡ 0
  ensure (unflagged.grid.get 0 0).isHidden "Cell should be hidden again"

test "Cannot flag revealed cell" := do
  let state := GameState.new beginner 12345
  let rng := RNG.new 54321
  let (gridWithMines, _) := generateMines state.grid ⟨4, 4⟩ 10 rng
  -- Reveal a cell first
  let gridRevealed := gridWithMines.modify 0 0 (fun c => { c with state := .revealed })
  let state' := { state with
    grid := gridRevealed
    firstClick := false
    cursor := ⟨0, 0⟩
  }

  let result := toggleFlag state'
  result.flagCount ≡ 0  -- Should not change
  ensure (result.grid.get 0 0).isRevealed "Cell should still be revealed"

test "Adjacent flag counting" := do
  let mut g := Grid.empty 5 5
  -- Flag cells around (2, 2)
  g := g.modify 1 1 (fun c => { c with state := .flagged })
  g := g.modify 2 1 (fun c => { c with state := .flagged })
  g := g.modify 3 1 (fun c => { c with state := .flagged })

  countAdjacentFlags g 2 2 ≡ 3

test "Win detection" := do
  let state := GameState.new beginner 12345
  -- Simulate winning: all non-mine cells revealed
  let state' := { state with revealedCount := 71 }  -- 81 - 10
  ensure state'.hasWon "Should have won"

test "Restart preserves difficulty" := do
  let state := GameState.new intermediate 12345
  let restarted := state.restart 54321
  restarted.difficulty ≡ intermediate
  restarted.status ≡ .playing
  ensure restarted.firstClick "Restarted game should be first click"

test "Change difficulty" := do
  let state := GameState.new beginner 12345
  let changed := state.changeDifficulty expert 54321
  changed.difficulty ≡ expert
  changed.grid.width ≡ 30
  changed.grid.height ≡ 16

end Minefield.Tests

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║        Minefield Test Suite            ║"
  IO.println "╚════════════════════════════════════════╝"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result == 0 then
    IO.println "✓ All tests passed!"
  else
    IO.println "✗ Some tests failed"

  return result
