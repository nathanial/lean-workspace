/-
  Twenty48.Game.State
  Game state structures
-/
import Twenty48.Core
import Terminus

namespace Twenty48.Game

open Twenty48.Core
open Terminus

/-- Animation phase for sequencing effects -/
inductive AnimPhase
  | idle       -- No animation running
  | sliding    -- Tiles moving to new positions
  | merging    -- Merge glow/flash effect
  | spawning   -- New tile pop-in effect
  deriving Repr, BEq, Inhabited

/-- Animation state for visual effects -/
structure AnimState where
  phase : AnimPhase
  timer : Nat                   -- Frames remaining in current phase

  -- Slide animation data
  slideDir : Core.Direction
  tileMovements : List TileMovement  -- Origin → destination mappings

  -- Merge animation data
  mergingCells : List Point     -- Cells that merged
  mergeValues : List Nat        -- Value after merge (for glow color)

  -- Spawn animation data
  newTilePos : Option Point     -- Position of newly spawned tile
  deriving Repr

def AnimState.default : AnimState :=
  { phase := .idle
  , timer := 0
  , slideDir := Core.Direction.up
  , tileMovements := []
  , mergingCells := []
  , mergeValues := []
  , newTilePos := none
  }

instance : Inhabited AnimState where
  default := AnimState.default

/-- Main game state -/
structure GameState where
  grid : Grid
  score : Nat
  bestScore : Nat
  bestTile : Nat                 -- Highest tile exponent achieved
  previousGrid : Option Grid     -- For undo
  previousScore : Option Nat
  won : Bool                     -- Created 2048 tile
  continuedAfterWin : Bool       -- Playing past 2048
  gameOver : Bool
  rng : UInt64
  anim : AnimState
  deriving Repr

/-- The winning tile exponent (2^11 = 2048) -/
def winningExponent : Nat := 11

/-- Create initial game state -/
def GameState.new (seed : UInt64) : GameState :=
  { grid := Grid.empty
  , score := 0
  , bestScore := 0
  , bestTile := 0
  , previousGrid := none
  , previousScore := none
  , won := false
  , continuedAfterWin := false
  , gameOver := false
  , rng := seed
  , anim := AnimState.default
  }

end Twenty48.Game
