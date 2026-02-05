/-
  Twenty48.Core.Types
  Basic types for the 2048 game
-/
import Terminus

namespace Twenty48.Core

/-- Grid dimensions -/
def gridSize : Nat := 4

/-- Direction of tile movement -/
inductive Direction
  | up
  | down
  | left
  | right
  deriving Repr, BEq, Inhabited

/-- A point on the grid -/
structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq, Inhabited

/-- A tile stores the exponent (2^n), or none for empty -/
abbrev Tile := Option Nat

/-- Get the displayed value of a tile -/
def tileValue : Tile → Nat
  | none => 0
  | some n => 2 ^ n

/-- Get the exponent from a value (for spawning) -/
def valueToExponent (v : Nat) : Nat :=
  if v == 2 then 1
  else if v == 4 then 2
  else 0  -- shouldn't happen

end Twenty48.Core
