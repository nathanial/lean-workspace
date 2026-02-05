/-
  Minefield.Game.State
  Game state structure
-/
import Minefield.Core

namespace Minefield.Game

open Minefield.Core

/-- Game status -/
inductive GameStatus where
  | playing   -- Game in progress
  | won       -- All non-mine cells revealed
  | lost      -- Mine was revealed
  deriving Repr, BEq, Inhabited

/-- Complete game state -/
structure GameState where
  grid : Grid
  difficulty : Difficulty
  status : GameStatus
  cursor : Point              -- Current cursor position
  flagCount : Nat             -- Number of flags placed
  revealedCount : Nat         -- Number of cells revealed
  firstClick : Bool           -- True until first reveal (mines not yet placed)
  startTime : Option Nat      -- Start time in milliseconds (None until first click)
  rng : RNG
  deriving Repr, Inhabited

/-- Create a new game state with the given difficulty -/
def GameState.new (difficulty : Difficulty) (seed : UInt64) : GameState := {
  grid := Grid.fromDifficulty difficulty
  difficulty := difficulty
  status := .playing
  cursor := ⟨difficulty.width / 2, difficulty.height / 2⟩
  flagCount := 0
  revealedCount := 0
  firstClick := true
  startTime := none
  rng := RNG.new seed
}

/-- Create a new beginner game -/
def GameState.newBeginner (seed : UInt64) : GameState :=
  GameState.new Minefield.Core.beginner seed

/-- Create a new intermediate game -/
def GameState.newIntermediate (seed : UInt64) : GameState :=
  GameState.new Minefield.Core.intermediate seed

/-- Create a new expert game -/
def GameState.newExpert (seed : UInt64) : GameState :=
  GameState.new Minefield.Core.expert seed

/-- Get the number of mines in the current game -/
def GameState.mineCount (s : GameState) : Nat :=
  s.difficulty.mines

/-- Get the number of remaining (unflagged) mines -/
def GameState.remainingMines (s : GameState) : Int :=
  (s.difficulty.mines : Int) - (s.flagCount : Int)

/-- Check if the game is over (won or lost) -/
def GameState.isGameOver (s : GameState) : Bool :=
  s.status != .playing

/-- Get the cell at the cursor -/
def GameState.cursorCell (s : GameState) : Cell :=
  s.grid.getPoint s.cursor

/-- Total number of non-mine cells -/
def GameState.nonMineCells (s : GameState) : Nat :=
  s.grid.totalCells - s.difficulty.mines

/-- Check if all non-mine cells are revealed (win condition) -/
def GameState.hasWon (s : GameState) : Bool :=
  s.revealedCount >= s.nonMineCells

/-- Reset the game with the same difficulty -/
def GameState.restart (s : GameState) (seed : UInt64) : GameState :=
  GameState.new s.difficulty seed

/-- Change difficulty and start new game -/
def GameState.changeDifficulty (_s : GameState) (d : Difficulty) (seed : UInt64) : GameState :=
  GameState.new d seed

end Minefield.Game
