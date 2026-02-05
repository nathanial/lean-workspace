/-
  Twenty48.UI.Draw
  Main draw function
-/
import Twenty48.Core
import Twenty48.Game
import Twenty48.UI.Widgets
import Terminus

namespace Twenty48.UI

open Twenty48.Core
open Twenty48.Game
open Terminus

/-- Main draw function -/
def draw (frame : Frame) (state : GameState) : Frame := Id.run do
  let area := frame.area
  let mut buf := frame.buffer

  -- Clear buffer
  buf := buf.fill Cell.empty

  -- Calculate layout
  let gridWidth := gridSize * tileCellWidth + 2
  let gridHeight := gridSize * tileCellHeight + 2
  let totalWidth := gridWidth + 18  -- Grid + sidebar
  let totalHeight := gridHeight + 6  -- Grid + title + score

  -- Center the game
  let startX := if area.width > totalWidth then (area.width - totalWidth) / 2 else 0
  let startY := if area.height > totalHeight then (area.height - totalHeight) / 2 else 0

  -- Render title
  buf := renderTitle buf startX startY

  -- Render score
  buf := renderScore buf state startX (startY + 4)

  -- Render grid
  let gridX := startX
  let gridY := startY + 6
  buf := renderGrid buf state gridX gridY

  -- Render controls (sidebar)
  let sideX := startX + gridWidth + 2
  let sideY := startY + 6
  buf := renderControls buf sideX sideY

  -- Render overlays
  let centerX := gridX + gridWidth / 2
  let centerY := gridY + gridHeight / 2

  if state.gameOver then
    buf := renderGameOver buf state centerX centerY
  else if state.won && !state.continuedAfterWin then
    buf := renderWin buf centerX centerY

  { frame with buffer := buf }

end Twenty48.UI
