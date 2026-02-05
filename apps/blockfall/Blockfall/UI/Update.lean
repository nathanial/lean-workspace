/-
  Blockfall.UI.Update
  Input handling and state updates
-/
import Blockfall.Core
import Blockfall.Game
import Terminus

namespace Blockfall.UI

open Blockfall.Core
open Blockfall.Game
open Terminus

/-- Process input and update game state. Returns (newState, shouldQuit) -/
def update (state : GameState) (event : Option Event) : GameState × Bool := Id.run do
  -- Apply gravity every frame
  let mut newState := applyGravity state

  match event with
  | none => (newState, false)
  | some (.key k) =>
    -- Handle quit
    if k.code == .char 'q' || k.code == .char 'Q' then
      return (newState, true)

    -- Handle restart (works even when paused or game over)
    if k.code == .char 'r' || k.code == .char 'R' then
      -- Use current time as seed for variety
      let seed : UInt64 := 12345  -- TODO: could use actual time
      return (restart newState seed, false)

    -- Handle pause toggle
    if k.code == .char 'p' || k.code == .char 'P' then
      return (togglePause newState, false)

    -- Don't process game input if paused or game over
    if newState.paused || newState.gameOver then
      return (newState, false)

    -- Movement keys
    match k.code with
    | .left | .char 'a' | .char 'A' =>
      (moveLeft newState, false)
    | .right | .char 'd' | .char 'D' =>
      (moveRight newState, false)
    | .down | .char 's' | .char 'S' =>
      (softDrop newState, false)
    | .up | .char 'w' | .char 'W' =>
      (rotate newState, false)
    | .space =>
      (hardDrop newState, false)
    | _ => (newState, false)

  | some (.resize _ _) =>
    -- Screen resize, just continue
    (newState, false)

  | _ => (newState, false)

end Blockfall.UI
