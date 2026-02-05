/-
  Minefield.Game.Logic
  Core game mechanics: reveal, flag, chord, win/lose detection
-/
import Minefield.Core
import Minefield.Game.State

namespace Minefield.Game

open Minefield.Core

/-- Move cursor in a direction, wrapping at edges -/
def moveCursor (s : GameState) (dir : Direction) : GameState :=
  let newCursor := match dir with
    | .up =>
      if s.cursor.y == 0 then ⟨s.cursor.x, s.grid.height - 1⟩
      else ⟨s.cursor.x, s.cursor.y - 1⟩
    | .down =>
      if s.cursor.y >= s.grid.height - 1 then ⟨s.cursor.x, 0⟩
      else ⟨s.cursor.x, s.cursor.y + 1⟩
    | .left =>
      if s.cursor.x == 0 then ⟨s.grid.width - 1, s.cursor.y⟩
      else ⟨s.cursor.x - 1, s.cursor.y⟩
    | .right =>
      if s.cursor.x >= s.grid.width - 1 then ⟨0, s.cursor.y⟩
      else ⟨s.cursor.x + 1, s.cursor.y⟩
  { s with cursor := newCursor }

/-- Reveal all mines (called on game over) -/
def revealAllMines (g : Grid) : Grid := Id.run do
  let mut grid := g
  for y in List.range g.height do
    for x in List.range g.width do
      let cell := grid.get x y
      if cell.hasMine then
        grid := grid.set x y { cell with state := .revealed }
  grid

/-- Flood-fill reveal from a cell (for cells with 0 adjacent mines) -/
partial def floodReveal (g : Grid) (x y : Nat) (revealed : Nat) : Grid × Nat := Id.run do
  let cell := g.get x y
  -- Only flood-fill from hidden cells
  if !cell.isHidden then return (g, revealed)
  -- Reveal this cell
  let mut grid := g.set x y { cell with state := .revealed }
  let mut count := revealed + 1

  -- If it's a zero cell, reveal all neighbors
  if cell.adjacentMines == 0 then
    for neighbor in g.neighbors x y do
      let neighborCell := grid.getPoint neighbor
      if neighborCell.isHidden then
        let (newGrid, newCount) := floodReveal grid neighbor.x neighbor.y count
        grid := newGrid
        count := newCount
  (grid, count)

/-- Reveal a single cell at position. Returns updated state. -/
def revealCell (s : GameState) (x y : Nat) (currentTime : Nat) : GameState := Id.run do
  -- Can't reveal if game is over
  if s.isGameOver then return s

  let cell := s.grid.get x y
  -- Can't reveal flagged or already revealed cells
  if cell.isFlagged || cell.isRevealed then return s

  let mut state := s

  -- Handle first click: generate mines with safe zone
  if state.firstClick then
    let (newGrid, newRng) := generateMines state.grid ⟨x, y⟩ state.difficulty.mines state.rng
    state := { state with
      grid := newGrid
      rng := newRng
      firstClick := false
      startTime := some currentTime
    }

  -- Get the cell again (may have changed after mine generation)
  let cell := state.grid.get x y

  -- Check if we hit a mine
  if cell.hasMine then
    let newGrid := revealAllMines state.grid
    return { state with
      grid := newGrid.set x y { cell with state := .revealed }
      status := .lost
    }

  -- Reveal the cell (and flood-fill if zero)
  let (newGrid, newRevealed) := floodReveal state.grid x y state.revealedCount
  state := { state with
    grid := newGrid
    revealedCount := newRevealed
  }

  -- Check win condition
  if state.hasWon then
    state := { state with status := .won }

  state

/-- Reveal cell at cursor -/
def reveal (s : GameState) (currentTime : Nat) : GameState :=
  revealCell s s.cursor.x s.cursor.y currentTime

/-- Toggle flag on a cell -/
def toggleFlag (s : GameState) : GameState := Id.run do
  -- Can't flag if game is over or before first click
  if s.isGameOver || s.firstClick then return s

  let cell := s.grid.getPoint s.cursor
  -- Can't flag revealed cells
  if cell.isRevealed then return s

  let (newState, newCount) := match cell.state with
    | .hidden => (.flagged, s.flagCount + 1)
    | .flagged => (.hidden, s.flagCount - 1)
    | .revealed => (.revealed, s.flagCount)  -- Shouldn't happen

  let newCell := { cell with state := newState }
  { s with
    grid := s.grid.setPoint s.cursor newCell
    flagCount := newCount
  }

/-- Count adjacent flags around a cell -/
def countAdjacentFlags (g : Grid) (x y : Nat) : Nat :=
  (g.neighbors x y).foldl (fun count neighbor =>
    if (g.getPoint neighbor).isFlagged then count + 1 else count
  ) 0

/-- Chord: reveal all unflagged neighbors if flag count matches number.
    If a flag was placed incorrectly, this can trigger game over. -/
def chord (s : GameState) (currentTime : Nat) : GameState := Id.run do
  -- Can't chord if game is over or before first click
  if s.isGameOver || s.firstClick then return s

  let cell := s.grid.getPoint s.cursor
  -- Can only chord on revealed number cells
  if !cell.isRevealed || cell.adjacentMines == 0 then return s

  -- Check if flag count matches
  let flagCount := countAdjacentFlags s.grid s.cursor.x s.cursor.y
  if flagCount != cell.adjacentMines then return s

  -- Reveal all unflagged neighbors
  let mut state := s
  for neighbor in s.grid.neighborsPoint s.cursor do
    let neighborCell := state.grid.getPoint neighbor
    if neighborCell.isHidden then
      state := revealCell state neighbor.x neighbor.y currentTime
      -- Stop if we lost
      if state.status == .lost then return state

  state

end Minefield.Game
