/-
  Blockfall.Game.State
  Game state structure
-/
import Blockfall.Core
import Blockfall.Game.Random
import Blockfall.Game.Scoring
import Terminus

namespace Blockfall.Game

open Blockfall.Core
open Terminus

/-- Animation state for visual effects -/
structure AnimState where
  -- Line clear animation
  clearingRows : List Nat     -- rows being cleared (empty = no animation)
  clearTimer : Nat            -- frames remaining (0 = done)
  pendingBoard : Option Board -- board state after clearing (delayed)

  -- Hard drop trail
  dropTrailCells : List Point -- piece shape for trail
  dropTrailStartY : Int       -- where drop started
  dropTrailEndY : Int         -- where drop ended
  dropTrailColor : Color      -- piece color
  dropTrailTimer : Nat
  dropTrailX : Int            -- X position for trail

  -- Piece lock flash
  lockFlashCells : List Point -- cells that just locked
  lockFlashColor : Color
  lockFlashTimer : Nat

  -- Game over fill
  gameOverFillRow : Nat       -- current row being filled (from bottom up)
  gameOverFillTimer : Nat
  deriving Repr

/-- Default animation state -/
def AnimState.default : AnimState := {
  clearingRows := []
  clearTimer := 0
  pendingBoard := none
  dropTrailCells := []
  dropTrailStartY := 0
  dropTrailEndY := 0
  dropTrailColor := .white
  dropTrailTimer := 0
  dropTrailX := 0
  lockFlashCells := []
  lockFlashColor := .white
  lockFlashTimer := 0
  gameOverFillRow := 0
  gameOverFillTimer := 0
}

instance : Inhabited AnimState where
  default := AnimState.default

/-- Complete game state -/
structure GameState where
  board : Board
  current : Piece
  currentPos : Point
  next : PieceType
  bag : Bag
  score : Nat
  level : Nat
  linesCleared : Nat
  tickCounter : Nat
  gameOver : Bool
  paused : Bool
  anim : AnimState
  deriving Repr, Inhabited

/-- Create initial game state -/
def GameState.new (seed : UInt64) : GameState := Id.run do
  let rng := RNG.new seed
  let mut bag := Bag.new rng
  let (firstType, bag') := bag.next
  bag := bag'
  let nextType := bag.peek
  {
    board := Board.empty
    current := Piece.fromType firstType
    currentPos := spawnPos
    next := nextType
    bag := bag
    score := 0
    level := 1
    linesCleared := 0
    tickCounter := 0
    gameOver := false
    paused := false
    anim := AnimState.default
  }

/-- Spawn a new piece -/
def GameState.spawnPiece (state : GameState) : GameState :=
  let (nextType, newBag) := state.bag.next
  let newPiece := Piece.fromType state.next
  let over := isGameOver state.board newPiece
  let anim := if over then
    { state.anim with
      gameOverFillRow := boardHeight - 1
      gameOverFillTimer := 2
    }
  else state.anim
  { state with
    current := newPiece
    currentPos := spawnPos
    next := nextType
    bag := newBag
    gameOver := over
    anim := anim
  }

/-- Get the ghost piece Y position -/
def GameState.ghostY (state : GameState) : Int :=
  Blockfall.Core.ghostY state.board state.current state.currentPos

/-- Current gravity delay based on level -/
def GameState.gravityDelay (state : GameState) : Nat :=
  Blockfall.Game.gravityDelay state.level

end Blockfall.Game
