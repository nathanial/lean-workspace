/-
  Twenty48.UI.App
  Main application entry point
-/
import Twenty48.Core
import Twenty48.Game
import Twenty48.UI.Draw
import Twenty48.UI.Update
import Terminus

namespace Twenty48.UI

open Twenty48.Game
open Terminus

/-- Run the game -/
def run : IO Unit := do
  -- Get seed from current time
  let now ← IO.monoMsNow
  let seed := now.toUInt64

  -- Create initial state with two tiles
  let initialState := initGame seed

  -- Run the game loop
  App.runApp initialState draw update

end Twenty48.UI
