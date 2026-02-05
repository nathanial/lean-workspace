/-
  Blockfall Tests
-/
import Crucible
import Blockfall

namespace Blockfall.Tests

open Crucible
open Blockfall.Core
open Blockfall.Game

testSuite "Blockfall Tests"

-- Core Types Tests

test "Point addition" := do
  let p1 : Point := ⟨1, 2⟩
  let p2 : Point := ⟨3, 4⟩
  let sum := p1 + p2
  sum.x ≡ 4
  sum.y ≡ 6

test "Direction offsets" := do
  Direction.left.toOffset.x ≡ -1
  Direction.right.toOffset.x ≡ 1
  Direction.down.toOffset.y ≡ 1

-- Piece Tests

test "All piece types defined" := do
  PieceType.all.length ≡ 7

test "Piece cells count" := do
  -- Each piece has exactly 4 cells
  for t in PieceType.all do
    let cells := t.cells 0
    ensure (cells.length == 4) s!"Piece {repr t} should have 4 cells"

test "O piece doesn't change on rotation" := do
  let cells0 := PieceType.O.cells 0
  let cells1 := PieceType.O.cells 1
  let cells2 := PieceType.O.cells 2
  let cells3 := PieceType.O.cells 3
  ensure (cells0 == cells1) "O piece rotation 0 should equal 1"
  ensure (cells1 == cells2) "O piece rotation 1 should equal 2"
  ensure (cells2 == cells3) "O piece rotation 2 should equal 3"

test "Piece rotation cycles" := do
  let p := Piece.fromType .T
  let p1 := p.rotateCW
  let p2 := p1.rotateCW
  let p3 := p2.rotateCW
  let p4 := p3.rotateCW
  p4.rotation ≡ 0  -- Should cycle back

-- Board Tests

test "Empty board" := do
  let board := Board.empty
  for x in List.range boardWidth do
    for y in List.range boardHeight do
      ensure (board.get x y == none) s!"Cell ({x}, {y}) should be empty"

test "Board set and get" := do
  let board := Board.empty
  let board' := board.set 5 10 (some .red)
  board'.get 5 10 ≡ some .red
  board'.get 0 0 ≡ none

test "Row completion detection" := do
  let mut board := Board.empty
  -- Fill one row
  for x in List.range boardWidth do
    board := board.set x 19 (some .blue)
  ensure (board.isRowComplete 19) "Row 19 should be complete"
  ensure (!board.isRowComplete 0) "Row 0 should not be complete"

test "Line clearing" := do
  let mut board := Board.empty
  -- Fill bottom row
  for x in List.range boardWidth do
    board := board.set x 19 (some .cyan)
  -- Add one cell above
  board := board.set 5 18 (some .red)

  let (cleared, count) := board.clearLines
  count ≡ 1
  -- The cell above should have shifted down
  cleared.get 5 19 ≡ some .red

test "Incomplete row is NOT complete" := do
  let mut board := Board.empty
  -- Fill all but one cell in a row
  for x in List.range (boardWidth - 1) do
    board := board.set x 19 (some .cyan)
  -- Leave position 9 empty (the last cell)
  ensure (!board.isRowComplete 19) "Row with gap should NOT be complete"
  -- Verify the gap exists
  board.get 9 19 ≡ none
  board.get 0 19 ≡ some .cyan

test "Row with single cell is NOT complete" := do
  let mut board := Board.empty
  board := board.set 5 10 (some .red)
  ensure (!board.isRowComplete 10) "Row with single cell should NOT be complete"

test "Row with alternating cells is NOT complete" := do
  let mut board := Board.empty
  -- Fill every other cell
  for x in List.range boardWidth do
    if x % 2 == 0 then
      board := board.set x 15 (some .blue)
  ensure (!board.isRowComplete 15) "Row with alternating cells should NOT be complete"

test "Incomplete rows are NOT cleared" := do
  let mut board := Board.empty
  -- Fill row 19 completely
  for x in List.range boardWidth do
    board := board.set x 19 (some .cyan)
  -- Fill row 18 with a gap at position 5
  for x in List.range boardWidth do
    if x != 5 then
      board := board.set x 18 (some .red)
  -- Verify row 18 has a gap
  board.get 5 18 ≡ none

  let (cleared, count) := board.clearLines
  count ≡ 1  -- Only row 19 should be cleared

  -- Row 18 (now at 19 after shift) should still have the gap
  cleared.get 5 19 ≡ none
  cleared.get 0 19 ≡ some .red

test "Multiple complete rows cleared" := do
  let mut board := Board.empty
  -- Fill rows 18 and 19 completely
  for x in List.range boardWidth do
    board := board.set x 18 (some .cyan)
    board := board.set x 19 (some .red)
  -- Add a cell above
  board := board.set 3 17 (some .green)

  let (cleared, count) := board.clearLines
  count ≡ 2
  -- The cell at 17 should now be at 19
  cleared.get 3 19 ≡ some .green

test "Board dimensions are correct" := do
  boardWidth ≡ 10
  boardHeight ≡ 20
  let board := Board.empty
  board.cells.size ≡ 20
  for row in board.cells do
    ensure (row.size == 10) s!"Row should have 10 cells, has {row.size}"

test "completeRows returns correct indices" := do
  let mut board := Board.empty
  -- Fill rows 5 and 15 completely
  for x in List.range boardWidth do
    board := board.set x 5 (some .cyan)
    board := board.set x 15 (some .red)
  -- Fill row 10 with a gap
  for x in List.range boardWidth do
    if x != 3 then
      board := board.set x 10 (some .green)

  let complete := board.completeRows
  ensure (complete.contains 5) "Row 5 should be complete"
  ensure (complete.contains 15) "Row 15 should be complete"
  ensure (!complete.contains 10) "Row 10 should NOT be complete (has gap)"
  complete.length ≡ 2

-- Collision Tests

test "Collision with floor" := do
  let board := Board.empty
  let piece := Piece.fromType .O
  let pos : Point := ⟨4, 19⟩  -- At bottom
  ensure (collides board piece pos) "Piece at bottom should collide"

test "Collision with walls" := do
  let board := Board.empty
  let piece := Piece.fromType .I
  let posLeft : Point := ⟨-1, 5⟩
  let posRight : Point := ⟨8, 5⟩
  ensure (collides board piece posLeft) "Piece past left wall should collide"
  ensure (collides board piece posRight) "Piece past right wall should collide"

test "No collision in valid position" := do
  let board := Board.empty
  let piece := Piece.fromType .T
  let pos := spawnPos
  ensure (!collides board piece pos) "Piece at spawn should not collide"

-- Ghost piece test

test "Ghost Y calculation" := do
  let board := Board.empty
  let piece := Piece.fromType .O
  let pos := spawnPos
  let ghost := ghostY board piece pos
  -- Ghost should be near the bottom
  ensure (ghost > 15) "Ghost should be near bottom on empty board"

-- Scoring Tests

test "Line scoring" := do
  linePoints 1 1 ≡ 100   -- Single at level 1
  linePoints 4 1 ≡ 800   -- Tetris at level 1
  linePoints 2 5 ≡ 1500  -- Double at level 5

test "Level calculation" := do
  levelFromLines 0 ≡ 1
  levelFromLines 9 ≡ 1
  levelFromLines 10 ≡ 2
  levelFromLines 25 ≡ 3

-- Game State Tests

test "Initial state" := do
  let state := GameState.new 12345
  state.score ≡ 0
  state.level ≡ 1
  state.linesCleared ≡ 0
  ensure (!state.gameOver) "Game should not be over initially"
  ensure (!state.paused) "Game should not be paused initially"

test "Movement" := do
  let state := GameState.new 12345
  let startX := state.currentPos.x
  let movedLeft := moveLeft state
  let movedRight := moveRight state
  movedLeft.currentPos.x ≡ startX - 1
  movedRight.currentPos.x ≡ startX + 1

test "Pause toggle" := do
  let state := GameState.new 12345
  ensure (!state.paused) "Should start unpaused"
  let paused := togglePause state
  ensure paused.paused "Should be paused after toggle"
  let unpaused := togglePause paused
  ensure (!unpaused.paused) "Should be unpaused after second toggle"

-- Property-based tests for line clearing

/-- Generate a random board with some filled rows -/
def genRandomBoard (seedVal : UInt64) : Board := Id.run do
  let mut board := Board.empty
  let mut rng := seedVal
  for y in List.range boardHeight do
    -- Decide if this row should be filled (50% chance)
    rng := rng * 6364136223846793005 + 1442695040888963407
    let fillRow := (rng % 2) == 0
    if fillRow then
      -- Fill the row, maybe with a gap
      rng := rng * 6364136223846793005 + 1442695040888963407
      let hasGap := (rng % 3) == 0  -- 33% chance of gap
      rng := rng * 6364136223846793005 + 1442695040888963407
      let gapPos := (rng % boardWidth.toUInt64).toNat
      for x in List.range boardWidth do
        if !hasGap || x != gapPos then
          board := board.set x y (some .cyan)
  board

test "Property: clearLines preserves board height" := do
  -- Test with multiple random seeds
  for seedVal in [1, 42, 123, 9999, 0xDEADBEEF] do
    let board := genRandomBoard seedVal
    let (cleared, _) := board.clearLines
    ensure (cleared.cells.size == boardHeight)
      s!"Board height should be preserved (seed {seedVal})"

test "Property: no complete rows after clearing" := do
  for seedVal in [1, 42, 123, 9999, 0xDEADBEEF, 7777, 12345] do
    let board := genRandomBoard seedVal
    let (cleared, _) := board.clearLines
    let remainingComplete := cleared.completeRows
    ensure remainingComplete.isEmpty
      s!"No complete rows should remain after clearing (seed {seedVal})"

test "Property: cleared count matches complete rows" := do
  for seedVal in [1, 42, 123, 9999, 0xDEADBEEF] do
    let board := genRandomBoard seedVal
    let completeBefore := board.completeRows.length
    let (_, count) := board.clearLines
    ensure (count == completeBefore)
      s!"Cleared count should match complete rows (seed {seedVal})"

test "Property: rows with gaps are never cleared" := do
  -- Create a board with one complete row and one row with gap
  for gapX in List.range boardWidth do
    let mut board := Board.empty
    -- Row 19: complete
    for x in List.range boardWidth do
      board := board.set x 19 (some .cyan)
    -- Row 18: has gap at gapX
    for x in List.range boardWidth do
      if x != gapX then
        board := board.set x 18 (some .red)

    let (cleared, count) := board.clearLines
    ensure (count == 1) s!"Only 1 row should clear (gap at {gapX})"
    -- The row with gap should have shifted down to 19 and still have gap
    ensure (cleared.get gapX 19 == none)
      s!"Gap at {gapX} should still exist after shift"

test "Property: row content preserved after shift" := do
  let mut board := Board.empty
  -- Fill row 19 completely (will be cleared)
  for x in List.range boardWidth do
    board := board.set x 19 (some .cyan)
  -- Put distinct values in row 18
  for x in List.range boardWidth do
    if x % 2 == 0 then
      board := board.set x 18 (some .red)

  let (cleared, count) := board.clearLines
  count ≡ 1
  -- Row 18's content should now be at row 19
  for x in List.range boardWidth do
    if x % 2 == 0 then
      cleared.get x 19 ≡ some .red
    else
      cleared.get x 19 ≡ none

test "Property: 4 complete rows (Tetris) cleared correctly" := do
  let mut board := Board.empty
  -- Fill rows 16, 17, 18, 19 completely
  for y in [16, 17, 18, 19] do
    for x in List.range boardWidth do
      board := board.set x y (some .cyan)
  -- Add a cell at row 15
  board := board.set 5 15 (some .red)

  let (cleared, count) := board.clearLines
  count ≡ 4
  -- The cell at 15 should now be at 19
  cleared.get 5 19 ≡ some .red
  -- Rows 15-18 should be empty now
  for y in [15, 16, 17, 18] do
    for x in List.range boardWidth do
      ensure (cleared.get x y == none)
        s!"Row {y} col {x} should be empty after Tetris clear"

end Blockfall.Tests

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║        Blockfall Test Suite            ║"
  IO.println "╚════════════════════════════════════════╝"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result == 0 then
    IO.println "✓ All tests passed!"
  else
    IO.println "✗ Some tests failed"

  return result
