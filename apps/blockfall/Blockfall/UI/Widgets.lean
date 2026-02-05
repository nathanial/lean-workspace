/-
  Blockfall.UI.Widgets
  Custom rendering functions for game elements
-/
import Blockfall.Core
import Blockfall.Game
import Terminus

namespace Blockfall.UI

open Blockfall.Core
open Blockfall.Game
open Terminus

/-- Block characters for rendering -/
def filledBlock : String := "██"
def ghostBlock : String := "▒▒"
def emptyCell : String := "· "

/-- Render a single cell to the buffer -/
def renderCell (buf : Buffer) (screenX screenY : Nat) (color : Option Color) (isGhost : Bool := false) : Buffer :=
  match color with
  | some c =>
    let style := if isGhost then Style.default.withFg ghostColor else Style.default.withFg c
    let char := if isGhost then ghostBlock else filledBlock
    buf.writeString screenX screenY char style
  | none =>
    buf.writeString screenX screenY emptyCell Style.default

/-- Render the game board with borders -/
def renderBoard (buf : Buffer) (state : GameState) (boardX boardY : Nat) : Buffer := Id.run do
  let mut result := buf

  -- Draw border
  let borderStyle := Style.default.withFg .white

  -- Top border
  let hLine := String.ofList (List.replicate (boardWidth * 2) '─')
  result := result.writeString boardX boardY ("┌" ++ hLine ++ "┐") borderStyle

  -- Side borders and cells
  for row in List.range boardHeight do
    let y := boardY + row + 1
    result := result.writeString boardX y "│" borderStyle
    result := result.writeString (boardX + boardWidth * 2 + 1) y "│" borderStyle

  -- Bottom border
  result := result.writeString boardX (boardY + boardHeight + 1) ("└" ++ hLine ++ "┘") borderStyle

  -- Draw locked cells
  for row in List.range boardHeight do
    for col in List.range boardWidth do
      let cell := state.board.get col row
      let screenX := boardX + 1 + col * 2
      let screenY := boardY + 1 + row
      result := renderCell result screenX screenY cell

  -- Draw ghost piece
  let ghostYPos := state.ghostY
  if ghostYPos != state.currentPos.y then
    for cell in state.current.cellsAt ⟨state.currentPos.x, ghostYPos⟩ do
      if cell.y >= 0 && cell.y < boardHeight then
        let screenX := boardX + 1 + cell.x.toNat * 2
        let screenY := boardY + 1 + cell.y.toNat
        result := renderCell result screenX screenY (some state.current.color) true

  -- Draw current piece
  for cell in state.current.cellsAt state.currentPos do
    if cell.y >= 0 && cell.y < boardHeight then
      let screenX := boardX + 1 + cell.x.toNat * 2
      let screenY := boardY + 1 + cell.y.toNat
      result := renderCell result screenX screenY (some state.current.color)

  result

/-- Render the next piece preview -/
def renderNextPiece (buf : Buffer) (pieceType : PieceType) (x y : Nat) : Buffer := Id.run do
  let mut result := buf

  -- Draw box
  let borderStyle := Style.default.withFg .white
  result := result.writeString x y "┌────────┐" borderStyle
  result := result.writeString x (y + 1) "│  NEXT  │" borderStyle
  result := result.writeString x (y + 2) "├────────┤" borderStyle
  for row in [3, 4, 5, 6] do
    result := result.writeString x (y + row) "│        │" borderStyle
  result := result.writeString x (y + 7) "└────────┘" borderStyle

  -- Draw piece (centered in preview box)
  let piece := Piece.fromType pieceType
  let previewX := x + 2
  let previewY := y + 4
  for cell in piece.cells do
    let screenX := previewX + cell.x.toNat * 2
    let screenY := previewY + cell.y.toNat
    if screenY < y + 7 then  -- Stay within box
      result := result.writeString screenX screenY filledBlock (Style.default.withFg pieceType.color)

  result

/-- Render score and stats -/
def renderStats (buf : Buffer) (state : GameState) (x y : Nat) : Buffer := Id.run do
  let mut result := buf
  let style := Style.default.withFg .white
  let valueStyle := Style.default.withFg .cyan

  result := result.writeString x y "Score:" style
  result := result.writeString (x + 7) y (toString state.score) valueStyle

  result := result.writeString x (y + 1) "Level:" style
  result := result.writeString (x + 7) (y + 1) (toString state.level) valueStyle

  result := result.writeString x (y + 2) "Lines:" style
  result := result.writeString (x + 7) (y + 2) (toString state.linesCleared) valueStyle

  result

/-- Render controls help -/
def renderControls (buf : Buffer) (x y : Nat) : Buffer := Id.run do
  let mut result := buf
  let borderStyle := Style.default.withFg .white
  let keyStyle := Style.default.withFg .yellow
  let descStyle := Style.default.withFg .white

  result := result.writeString x y "┌──────────┐" borderStyle
  result := result.writeString x (y + 1) "│ CONTROLS │" borderStyle
  result := result.writeString x (y + 2) "├──────────┤" borderStyle

  let controls := [
    ("←→", "Move"),
    ("↑", "Rotate"),
    ("↓", "Soft"),
    ("Space", "Drop"),
    ("P", "Pause"),
    ("R", "Restart"),
    ("Q", "Quit")
  ]

  for i in List.range controls.length do
    if h : i < controls.length then
      let (key, desc) := controls[i]
      let lineY := y + 3 + i
      result := result.writeString x lineY "│" borderStyle
      result := result.writeString (x + 1) lineY key keyStyle
      result := result.writeString (x + 6) lineY desc descStyle
      result := result.writeString (x + 11) lineY "│" borderStyle

  result := result.writeString x (y + 10) "└──────────┘" borderStyle
  result

/-- Render title -/
def renderTitle (buf : Buffer) (x y : Nat) (width : Nat) : Buffer := Id.run do
  let title := "BLOCKFALL"
  let titleX := x + (width - title.length) / 2
  let style := Style.default.withFg .cyan |>.withModifier { bold := true }
  buf.writeString titleX y title style

/-- Render game over overlay -/
def renderGameOver (buf : Buffer) (state : GameState) (x y width height : Nat) : Buffer := Id.run do
  let mut result := buf

  let centerY := y + height / 2
  let boxWidth := 20
  let boxX := x + (width - boxWidth) / 2

  let borderStyle := Style.default.withFg .red
  let scoreStyle := Style.default.withFg .yellow

  result := result.writeString boxX (centerY - 2) "┌──────────────────┐" borderStyle
  result := result.writeString boxX (centerY - 1) "│    GAME OVER     │" borderStyle
  result := result.writeString boxX centerY "│                  │" borderStyle

  let scoreText := s!"Score: {state.score}"
  let scoreX := boxX + 1 + (18 - scoreText.length) / 2
  result := result.writeString scoreX centerY scoreText scoreStyle

  result := result.writeString boxX (centerY + 1) "│  Press R to play │" borderStyle
  result := result.writeString boxX (centerY + 2) "└──────────────────┘" borderStyle

  result

/-- Render pause overlay -/
def renderPaused (buf : Buffer) (x y width height : Nat) : Buffer := Id.run do
  let mut result := buf

  let centerY := y + height / 2
  let boxWidth := 14
  let boxX := x + (width - boxWidth) / 2

  let style := Style.default.withFg .yellow

  result := result.writeString boxX (centerY - 1) "┌────────────┐" style
  result := result.writeString boxX centerY "│   PAUSED   │" style
  result := result.writeString boxX (centerY + 1) "└────────────┘" style

  result

/-- Character for trail rendering -/
def trailBlock : String := "░░"

/-- Render hard drop trail animation -/
def renderDropTrail (buf : Buffer) (anim : AnimState) (boardX boardY : Nat) : Buffer := Id.run do
  if anim.dropTrailTimer == 0 then return buf

  let mut result := buf

  -- Fade based on timer: 4=bright, 3=medium, 2=dim, 1=very dim
  let intensity := anim.dropTrailTimer
  let style := if intensity >= 3 then
    Style.default.withFg anim.dropTrailColor
  else
    Style.default.withFg ghostColor

  -- Render the piece shape at intervals from startY to endY-1
  -- (endY is where the piece landed, don't draw there)
  for y in List.range ((anim.dropTrailEndY - anim.dropTrailStartY).toNat) do
    let trailY := anim.dropTrailStartY + y
    if trailY >= 0 && trailY < boardHeight then
      for cell in anim.dropTrailCells do
        let cellX := anim.dropTrailX + cell.x
        let cellY := trailY + cell.y
        if cellX >= 0 && cellX < boardWidth && cellY >= 0 && cellY < boardHeight then
          let screenX := boardX + 1 + cellX.toNat * 2
          let screenY := boardY + 1 + cellY.toNat
          result := result.writeString screenX screenY trailBlock style

  result

/-- Render lock flash animation -/
def renderLockFlash (buf : Buffer) (anim : AnimState) (boardX boardY : Nat) : Buffer := Id.run do
  if anim.lockFlashTimer == 0 then return buf

  let mut result := buf

  -- Flash with white color
  let flashStyle := Style.default.withFg .white |>.withModifier { bold := true }

  for cell in anim.lockFlashCells do
    if cell.y >= 0 && cell.y < boardHeight && cell.x >= 0 && cell.x < boardWidth then
      let screenX := boardX + 1 + cell.x.toNat * 2
      let screenY := boardY + 1 + cell.y.toNat
      result := result.writeString screenX screenY filledBlock flashStyle

  result

/-- Render line clear flash animation -/
def renderClearingRows (buf : Buffer) (anim : AnimState) (boardX boardY : Nat) : Buffer := Id.run do
  if anim.clearTimer == 0 then return buf

  let mut result := buf

  -- Flash: white on odd timer values, don't render (show original) on even
  if anim.clearTimer % 2 == 1 then
    let flashStyle := Style.default.withFg .white |>.withModifier { bold := true }
    for row in anim.clearingRows do
      if row < boardHeight then
        let screenY := boardY + 1 + row
        for col in List.range boardWidth do
          let screenX := boardX + 1 + col * 2
          result := result.writeString screenX screenY filledBlock flashStyle

  result

/-- Render game over fill animation -/
def renderGameOverFill (buf : Buffer) (anim : AnimState) (boardX boardY : Nat) : Buffer := Id.run do
  let mut result := buf

  -- Fill from bottom (boardHeight - 1) up to gameOverFillRow
  let fillStyle := Style.default.withFg ghostColor
  for row in List.range boardHeight do
    if row > anim.gameOverFillRow then
      let screenY := boardY + 1 + row
      for col in List.range boardWidth do
        let screenX := boardX + 1 + col * 2
        result := result.writeString screenX screenY filledBlock fillStyle

  result

end Blockfall.UI
