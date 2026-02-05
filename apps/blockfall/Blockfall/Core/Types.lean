/-
  Blockfall.Core.Types
  Core type definitions for the game
-/
import Terminus

namespace Blockfall.Core

/-- A 2D point with integer coordinates -/
structure Point where
  x : Int
  y : Int
  deriving Repr, BEq, Inhabited

instance : Add Point where
  add p1 p2 := ⟨p1.x + p2.x, p1.y + p2.y⟩

/-- Movement direction -/
inductive Direction where
  | left
  | right
  | down
  deriving Repr, BEq

/-- Convert direction to point offset -/
def Direction.toOffset : Direction → Point
  | .left  => ⟨-1, 0⟩
  | .right => ⟨1, 0⟩
  | .down  => ⟨0, 1⟩

/-- The 7 standard tetromino piece types -/
inductive PieceType where
  | I  -- Line piece
  | O  -- Square piece
  | T  -- T-shaped piece
  | S  -- S-shaped piece
  | Z  -- Z-shaped piece
  | J  -- J-shaped piece
  | L  -- L-shaped piece
  deriving Repr, BEq, Inhabited

/-- All piece types for iteration -/
def PieceType.all : List PieceType := [.I, .O, .T, .S, .Z, .J, .L]

/-- Get the color for a piece type -/
def PieceType.color : PieceType → Terminus.Color
  | .I => .cyan
  | .O => .yellow
  | .T => .magenta
  | .S => .green
  | .Z => .red
  | .J => .blue
  | .L => .indexed 208  -- Orange (256-color)

/-- Ghost piece color (dim gray) -/
def ghostColor : Terminus.Color := .indexed 240

/-- Board dimensions -/
def boardWidth : Nat := 10
def boardHeight : Nat := 20

/-- Spawn position for new pieces (top-center) -/
def spawnPos : Point := ⟨3, 0⟩

end Blockfall.Core
