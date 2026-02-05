/-
  Blockfall.UI.Draw
  Main drawing function
-/
import Blockfall.Core
import Blockfall.Game
import Blockfall.UI.Widgets
import Terminus

namespace Blockfall.UI

open Blockfall.Core
open Blockfall.Game
open Terminus

/-- Draw the complete game screen -/
def draw (frame : Frame) (state : GameState) : Frame := Id.run do
  let area := frame.area
  let mut buf := frame.buffer

  -- Clear buffer
  buf := buf.fill Cell.empty

  -- Calculate layout
  let boardScreenWidth := boardWidth * 2 + 2
  let boardScreenHeight := boardHeight + 2
  let sidebarWidth := 12
  let totalWidth := boardScreenWidth + sidebarWidth + 2

  -- Center the game area
  let startX := if area.width > totalWidth then (area.width - totalWidth) / 2 else 0
  let startY := if area.height > boardScreenHeight + 2 then (area.height - boardScreenHeight - 2) / 2 else 0

  -- Title
  buf := renderTitle buf startX startY totalWidth

  -- Board
  let boardX := startX
  let boardY := startY + 2
  buf := renderBoard buf state boardX boardY

  -- Animation layers (rendered on top of board)
  buf := renderDropTrail buf state.anim boardX boardY
  buf := renderLockFlash buf state.anim boardX boardY
  buf := renderClearingRows buf state.anim boardX boardY

  -- Game over fill (before overlay text)
  if state.gameOver then
    buf := renderGameOverFill buf state.anim boardX boardY

  -- Sidebar
  let sideX := startX + boardScreenWidth + 2
  let sideY := boardY

  -- Next piece preview
  buf := renderNextPiece buf state.next sideX sideY

  -- Stats
  buf := renderStats buf state sideX (sideY + 9)

  -- Controls
  buf := renderControls buf sideX (sideY + 13)

  -- Overlays
  if state.gameOver then
    buf := renderGameOver buf state boardX boardY boardScreenWidth boardScreenHeight
  else if state.paused then
    buf := renderPaused buf boardX boardY boardScreenWidth boardScreenHeight

  { frame with buffer := buf }

end Blockfall.UI
