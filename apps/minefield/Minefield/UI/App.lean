/-
  Minefield.UI.App
  Main game loop with timer support
-/
import Minefield.Core
import Minefield.Game
import Minefield.UI.Draw
import Minefield.UI.Update
import Terminus

namespace Minefield.UI

open Minefield.Core
open Minefield.Game
open Terminus

/-- Run a single frame with timing context -/
def tick (term : Terminal) (state : GameState) : IO (Terminal × GameState × Bool) := do
  -- Get current time for timer and randomization
  let currentTime ← IO.monoMsNow

  -- Poll for input
  let event ← Events.poll
  let optEvent := match event with
    | .none => none
    | e => some e

  -- Create update context
  let updateCtx : UpdateContext := {
    currentTime := currentTime
    seed := currentTime.toUInt64
  }

  -- Update state
  let (newState, shouldQuit) := update updateCtx state optEvent

  if shouldQuit then
    return (term, newState, true)

  -- Create draw context
  let drawCtx : DrawContext := {
    currentTime := currentTime
  }

  -- Create frame and render
  let frame := Frame.new term.area
  let frame := draw drawCtx frame newState

  -- Update terminal buffer and flush
  let term := term.setBuffer frame.buffer
  let term ← term.flush frame.commands

  pure (term, newState, false)

/-- Main run loop -/
partial def runLoop (term : Terminal) (state : GameState) : IO Unit := do
  let (term, state, shouldQuit) ← tick term state

  if shouldQuit then return

  IO.sleep 16  -- ~60 FPS
  runLoop term state

/-- Run the game -/
def run : IO Unit := do
  -- Get a seed from current time
  let now ← IO.monoMsNow
  let seed := now.toUInt64

  -- Create initial state with beginner difficulty
  let initialState := GameState.new beginner seed

  -- Setup terminal
  Terminal.setup
  try
    let term ← Terminal.new
    -- Initial draw
    let term ← term.draw
    runLoop term initialState
  finally
    Terminal.teardown

end Minefield.UI
