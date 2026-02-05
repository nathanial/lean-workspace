/-
  Blockfall.UI.App
  Main game loop
-/
import Blockfall.Core
import Blockfall.Game
import Blockfall.UI.Draw
import Blockfall.UI.Update
import Terminus

namespace Blockfall.UI

open Blockfall.Game
open Terminus

/-- Run the game -/
def run : IO Unit := do
  -- Get a seed from current time
  let now ← IO.monoMsNow
  let seed := now.toUInt64

  -- Create initial state
  let initialState := GameState.new seed

  -- Run the game loop
  App.runApp initialState draw update

end Blockfall.UI
