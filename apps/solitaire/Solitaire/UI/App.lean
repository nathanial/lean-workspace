/-
  Solitaire.UI.App
  Main game loop
-/
import Solitaire.Game
import Solitaire.UI.Draw
import Solitaire.UI.Update
import Terminus

namespace Solitaire.UI

open Solitaire.Game
open Terminus

/-- Run a single frame -/
def tick (term : Terminal) (state : GameState) (seed : UInt64) : IO (Terminal × GameState × Bool) := do
  -- Poll for input
  let event ← Events.poll
  let optEvent := match event with
    | .none => none
    | e => some e

  -- Create update context
  let updateCtx : UpdateContext := { seed }

  -- Update state
  let (newState, shouldQuit) := update updateCtx state optEvent

  if shouldQuit then
    return (term, newState, true)

  -- Create frame and render
  let frame := Frame.new term.area
  let frame := draw frame newState

  -- Update terminal buffer and flush
  let term := term.setBuffer frame.buffer
  let term ← term.flush frame.commands

  pure (term, newState, false)

/-- Main run loop -/
partial def runLoop (term : Terminal) (state : GameState) (seed : UInt64) : IO Unit := do
  let (term, state, shouldQuit) ← tick term state seed

  if shouldQuit then return

  IO.sleep 16  -- ~60 FPS
  runLoop term state seed

/-- Run the game -/
def run : IO Unit := do
  -- Get a seed from current time
  let now ← IO.monoMsNow
  let seed := now.toUInt64

  -- Create initial state
  let initialState := GameState.new seed

  -- Setup terminal
  Terminal.setup
  try
    let term ← Terminal.new
    -- Initial draw
    let term ← term.draw
    runLoop term initialState seed
  finally
    Terminal.teardown

end Solitaire.UI
