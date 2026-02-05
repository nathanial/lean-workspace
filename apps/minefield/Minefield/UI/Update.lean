/-
  Minefield.UI.Update
  Input handling and state updates
-/
import Minefield.Core
import Minefield.Game
import Terminus

namespace Minefield.UI

open Minefield.Core
open Minefield.Game
open Terminus

/-- Update context with timing info -/
structure UpdateContext where
  currentTime : Nat
  seed : UInt64  -- For restart randomization
  deriving Repr, Inhabited

/-- Process input and update game state. Returns (newState, shouldQuit) -/
def update (ctx : UpdateContext) (state : GameState) (event : Option Event) : GameState × Bool := Id.run do
  match event with
  | none => (state, false)
  | some (.key k) =>
    -- Handle quit
    if k.code == .char 'q' || k.code == .char 'Q' || k.isCtrlC then
      return (state, true)

    -- Handle restart (works even when game over)
    if k.code == .char 'r' || k.code == .char 'R' then
      return (state.restart ctx.seed, false)

    -- Handle difficulty change
    if k.code == .char '1' then
      return (state.changeDifficulty beginner ctx.seed, false)
    if k.code == .char '2' then
      return (state.changeDifficulty intermediate ctx.seed, false)
    if k.code == .char '3' then
      return (state.changeDifficulty expert ctx.seed, false)

    -- Don't process game input if game is over
    if state.isGameOver then
      return (state, false)

    -- Movement keys
    match k.code with
    | .up | .char 'w' | .char 'W' =>
      (moveCursor state .up, false)
    | .down | .char 's' | .char 'S' =>
      (moveCursor state .down, false)
    | .left | .char 'a' | .char 'A' =>
      (moveCursor state .left, false)
    | .right | .char 'd' | .char 'D' =>
      (moveCursor state .right, false)

    -- Reveal
    | .space | .enter =>
      (reveal state ctx.currentTime, false)

    -- Flag
    | .char 'f' | .char 'F' =>
      (toggleFlag state, false)

    -- Chord
    | .char 'c' | .char 'C' =>
      (chord state ctx.currentTime, false)

    | _ => (state, false)

  | some (.resize _ _) =>
    -- Screen resize, just continue
    (state, false)

  | _ => (state, false)

end Minefield.UI
