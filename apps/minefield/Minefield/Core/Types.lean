/-
  Minefield.Core.Types
  Core type definitions for the Minesweeper game
-/
import Terminus

namespace Minefield.Core

/-- A 2D point with natural coordinates -/
structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq, Inhabited

/-- Movement direction for cursor -/
inductive Direction where
  | up
  | down
  | left
  | right
  deriving Repr, BEq

/-- The state of a cell (visibility) -/
inductive CellState where
  | hidden    -- Not yet revealed, no flag
  | flagged   -- Marked with a flag
  | revealed  -- Cell has been revealed
  deriving Repr, BEq, Inhabited

/-- A single cell in the minefield grid -/
structure Cell where
  state : CellState := .hidden
  hasMine : Bool := false
  adjacentMines : Nat := 0
  deriving Repr, BEq, Inhabited

/-- Check if a cell is hidden (not revealed, not flagged) -/
def Cell.isHidden (c : Cell) : Bool :=
  c.state == .hidden

/-- Check if a cell is flagged -/
def Cell.isFlagged (c : Cell) : Bool :=
  c.state == .flagged

/-- Check if a cell is revealed -/
def Cell.isRevealed (c : Cell) : Bool :=
  c.state == .revealed

/-- Difficulty preset for the game -/
structure Difficulty where
  name : String
  width : Nat
  height : Nat
  mines : Nat
  deriving Repr, BEq, Inhabited

/-- Beginner difficulty: 9x9 grid with 10 mines -/
def beginner : Difficulty := ⟨"Beginner", 9, 9, 10⟩

/-- Intermediate difficulty: 16x16 grid with 40 mines -/
def intermediate : Difficulty := ⟨"Intermediate", 16, 16, 40⟩

/-- Expert difficulty: 30x16 grid with 99 mines -/
def expert : Difficulty := ⟨"Expert", 30, 16, 99⟩

/-- Get a difficulty by number (1, 2, or 3) -/
def difficultyByNumber : Nat → Difficulty
  | 1 => beginner
  | 2 => intermediate
  | 3 => expert
  | _ => beginner

/-- Colors for the numbers 1-8 (classic Minesweeper colors) -/
def numberColor : Nat → Terminus.Color
  | 1 => .blue
  | 2 => .green
  | 3 => .red
  | 4 => .indexed 18   -- Dark blue
  | 5 => .indexed 88   -- Dark red/brown
  | 6 => .cyan
  | 7 => .indexed 232  -- Black
  | 8 => .indexed 244  -- Gray
  | _ => .default

/-- Character representations -/
def hiddenChar : Char := '■'
def flagChar : Char := '⚑'
def emptyChar : Char := '·'
def mineChar : Char := '*'
def wrongFlagChar : Char := 'X'

end Minefield.Core
