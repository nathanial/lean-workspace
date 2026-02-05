/-
  Twenty48.UI.Update
  Input handling and state updates
-/
import Twenty48.Core
import Twenty48.Game
import Terminus

namespace Twenty48.UI

open Twenty48.Core
open Twenty48.Game
open Terminus

/-- Handle input and update game state -/
def update (state : GameState) (event : Option Event) : GameState × Bool := Id.run do
  -- Update animations every frame
  let mut newState := updateAnimations state

  match event with
  | none => (newState, false)

  | some (.key k) =>
    -- Quit always works (even during animation)
    if k.code == .char 'q' || k.code == .char 'Q' then
      return (newState, true)

    -- Block all other input during animations
    if newState.anim.phase != .idle then
      return (newState, false)

    -- Restart always works
    if k.code == .char 'r' || k.code == .char 'R' then
      return (restart newState, false)

    -- If showing win screen, only accept 'C' to continue
    if newState.won && !newState.continuedAfterWin then
      if k.code == .char 'c' || k.code == .char 'C' then
        return (continueAfterWin newState, false)
      return (newState, false)

    -- If game over, no moves allowed (must restart)
    if newState.gameOver then
      return (newState, false)

    -- Undo
    if k.code == .char 'u' || k.code == .char 'U' then
      return (undo newState, false)

    -- Movement
    match k.code with
    | .up    | .char 'w' | .char 'W' => (move newState .up, false)
    | .down  | .char 's' | .char 'S' => (move newState .down, false)
    | .left  | .char 'a' | .char 'A' => (move newState .left, false)
    | .right | .char 'd' | .char 'D' => (move newState .right, false)
    | _ => (newState, false)

  | some (.resize _ _) =>
    -- Handle resize by just continuing
    (newState, false)

  | _ => (newState, false)

end Twenty48.UI
