/-
  Minefield.UI.Draw
  Main drawing function
-/
import Minefield.Core
import Minefield.Game
import Minefield.UI.Widgets
import Terminus

namespace Minefield.UI

open Minefield.Core
open Minefield.Game
open Terminus

/-- Current time for timer display (stored in draw context) -/
structure DrawContext where
  currentTime : Nat
  deriving Repr, Inhabited

/-- Draw the complete game screen -/
def draw (ctx : DrawContext) (frame : Frame) (state : GameState) : Frame := Id.run do
  let area := frame.area
  let mut buf := frame.buffer

  -- Clear buffer
  buf := buf.fill Cell.empty

  -- Calculate layout
  let gridScreenWidth := state.grid.width * 2 + 2
  let gridScreenHeight := state.grid.height + 2
  let sidebarWidth := 20
  let totalWidth := gridScreenWidth + sidebarWidth + 2
  let totalHeight := gridScreenHeight + 4  -- title + status + grid

  -- Center the game area
  let startX := if area.width > totalWidth then (area.width - totalWidth) / 2 else 0
  let startY := if area.height > totalHeight then (area.height - totalHeight) / 2 else 0

  -- Title and difficulty
  buf := renderTitle buf startX startY
  buf := renderDifficulty buf state (startX + 12) startY

  -- Status bar
  buf := renderStatus buf state ctx.currentTime startX (startY + 1)

  -- Grid
  let gridX := startX
  let gridY := startY + 3
  buf := renderGrid buf state gridX gridY

  -- Sidebar with controls
  let sideX := startX + gridScreenWidth + 2
  let sideY := gridY
  buf := renderControls buf sideX sideY

  -- Win/Lose overlays
  match state.status with
  | .won =>
    buf := renderWinOverlay buf gridX gridY gridScreenWidth gridScreenHeight
  | .lost =>
    buf := renderGameOverOverlay buf gridX gridY gridScreenWidth gridScreenHeight
  | .playing =>
    pure ()

  { frame with buffer := buf }

end Minefield.UI
