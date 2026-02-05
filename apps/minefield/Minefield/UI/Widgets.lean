/-
  Minefield.UI.Widgets
  Custom rendering functions for game elements
-/
import Minefield.Core
import Minefield.Game
import Terminus

namespace Minefield.UI

open Minefield.Core
open Minefield.Game
open Terminus

/-- Get character and style for a cell -/
def cellAppearance (cell : Core.Cell) (isCursor : Bool) (isGameOver : Bool) : Char × Style := Id.run do
  let baseStyle := Style.default

  -- Determine character and color based on cell state
  let (char, style) := match cell.state with
    | .hidden =>
      (hiddenChar, baseStyle.withFg (.indexed 250))  -- Light gray
    | .flagged =>
      if isGameOver && !cell.hasMine then
        -- Wrong flag: show X
        (wrongFlagChar, baseStyle.withFg .red |>.withModifier { bold := true })
      else
        (flagChar, baseStyle.withFg .red |>.withModifier { bold := true })
    | .revealed =>
      if cell.hasMine then
        (mineChar, baseStyle.withFg .red |>.withBg .yellow |>.withModifier { bold := true })
      else if cell.adjacentMines == 0 then
        (emptyChar, baseStyle.withFg (.indexed 240))  -- Dim
      else
        let numChar := Char.ofNat (48 + cell.adjacentMines)  -- '0' + n
        (numChar, baseStyle.withFg (numberColor cell.adjacentMines) |>.withModifier { bold := true })

  -- Apply cursor highlight
  if isCursor then
    (char, style.withBg (.indexed 236) |>.withModifier { bold := true })
  else
    (char, style)

/-- Render a single cell to the buffer -/
def renderCell (buf : Buffer) (screenX screenY : Nat) (cell : Core.Cell) (isCursor : Bool) (isGameOver : Bool) : Buffer :=
  let (char, style) := cellAppearance cell isCursor isGameOver
  -- Use two characters per cell for better visual spacing
  let cellStr := s!"{char} "
  buf.writeString screenX screenY cellStr style

/-- Render the minefield grid -/
def renderGrid (buf : Buffer) (state : GameState) (gridX gridY : Nat) : Buffer := Id.run do
  let mut result := buf
  let isGameOver := state.isGameOver

  -- Draw border
  let borderStyle := Style.default.withFg .white

  -- Calculate border dimensions (2 chars per cell + 1 for spacing)
  let innerWidth := state.grid.width * 2
  let hLine := String.ofList (List.replicate innerWidth '─')

  -- Top border
  result := result.writeString gridX gridY ("┌" ++ hLine ++ "┐") borderStyle

  -- Side borders
  for row in List.range state.grid.height do
    let y := gridY + row + 1
    result := result.writeString gridX y "│" borderStyle
    result := result.writeString (gridX + innerWidth + 1) y "│" borderStyle

  -- Bottom border
  result := result.writeString gridX (gridY + state.grid.height + 1) ("└" ++ hLine ++ "┘") borderStyle

  -- Draw cells
  for row in List.range state.grid.height do
    for col in List.range state.grid.width do
      let cell := state.grid.get col row
      let isCursor := state.cursor.x == col && state.cursor.y == row
      let screenX := gridX + 1 + col * 2
      let screenY := gridY + 1 + row
      result := renderCell result screenX screenY cell isCursor isGameOver

  result

/-- Format time as MM:SS -/
def formatTime (elapsedMs : Nat) : String :=
  let totalSeconds := elapsedMs / 1000
  let minutes := totalSeconds / 60
  let seconds := totalSeconds % 60
  let minStr := if minutes < 10 then s!"0{minutes}" else toString minutes
  let secStr := if seconds < 10 then s!"0{seconds}" else toString seconds
  s!"{minStr}:{secStr}"

/-- Render the status bar -/
def renderStatus (buf : Buffer) (state : GameState) (currentTime : Nat) (x y : Nat) : Buffer := Id.run do
  let mut result := buf

  let labelStyle := Style.default.withFg .white
  let valueStyle := Style.default.withFg .cyan

  -- Mines remaining
  let remaining := state.remainingMines
  let mineStr := if remaining >= 0 then toString remaining else s!"{remaining}"
  result := result.writeString x y "Mines: " labelStyle
  result := result.writeString (x + 7) y mineStr valueStyle

  -- Timer
  let elapsed := match state.startTime with
    | some start => currentTime - start
    | none => 0
  let timeStr := formatTime elapsed
  result := result.writeString (x + 14) y "Time: " labelStyle
  result := result.writeString (x + 20) y timeStr valueStyle

  -- Status
  let (statusStr, statusStyle) := match state.status with
    | .playing => ("PLAYING", Style.default.withFg .green)
    | .won => ("YOU WIN!", Style.default.withFg .green |>.withModifier { bold := true })
    | .lost => ("GAME OVER", Style.default.withFg .red |>.withModifier { bold := true })
  result := result.writeString (x + 30) y s!"[{statusStr}]" statusStyle

  result

/-- Render controls help -/
def renderControls (buf : Buffer) (x y : Nat) : Buffer := Id.run do
  let mut result := buf
  let borderStyle := Style.default.withFg .white
  let keyStyle := Style.default.withFg .yellow
  let descStyle := Style.default.withFg (.indexed 250)

  result := result.writeString x y "┌─────────────────┐" borderStyle
  result := result.writeString x (y + 1) "│    CONTROLS     │" borderStyle
  result := result.writeString x (y + 2) "├─────────────────┤" borderStyle

  let controls := [
    ("↑↓←→/WASD", "Move"),
    ("Space/Enter", "Reveal"),
    ("F", "Flag"),
    ("C", "Chord"),
    ("R", "Restart"),
    ("1/2/3", "Difficulty"),
    ("Q", "Quit")
  ]

  for i in List.range controls.length do
    if h : i < controls.length then
      let (key, desc) := controls[i]
      let lineY := y + 3 + i
      result := result.writeString x lineY "│" borderStyle
      result := result.writeString (x + 2) lineY key keyStyle
      -- Right align description
      let descX := x + 17 - desc.length
      result := result.writeString descX lineY desc descStyle
      result := result.writeString (x + 18) lineY "│" borderStyle

  result := result.writeString x (y + 10) "├─────────────────┤" borderStyle
  result := result.writeString x (y + 11) "│   DIFFICULTY    │" borderStyle
  result := result.writeString x (y + 12) "├─────────────────┤" borderStyle

  let difficulties := [
    ("1", "Beginner  9x9"),
    ("2", "Intermed 16x16"),
    ("3", "Expert   30x16")
  ]

  for i in List.range difficulties.length do
    if h : i < difficulties.length then
      let (key, desc) := difficulties[i]
      let lineY := y + 13 + i
      result := result.writeString x lineY "│" borderStyle
      result := result.writeString (x + 2) lineY key keyStyle
      result := result.writeString (x + 4) lineY desc descStyle
      result := result.writeString (x + 18) lineY "│" borderStyle

  result := result.writeString x (y + 16) "└─────────────────┘" borderStyle
  result

/-- Render title -/
def renderTitle (buf : Buffer) (x y : Nat) : Buffer := Id.run do
  let title := "MINEFIELD"
  let style := Style.default.withFg .cyan |>.withModifier { bold := true }
  buf.writeString x y title style

/-- Render difficulty name -/
def renderDifficulty (buf : Buffer) (state : GameState) (x y : Nat) : Buffer :=
  let style := Style.default.withFg (.indexed 250)
  buf.writeString x y state.difficulty.name style

/-- Render win overlay -/
def renderWinOverlay (buf : Buffer) (x y width height : Nat) : Buffer := Id.run do
  let mut result := buf

  let centerY := y + height / 2
  let boxWidth := 22
  let boxX := x + (width - boxWidth) / 2

  let borderStyle := Style.default.withFg .green |>.withModifier { bold := true }
  let textStyle := Style.default.withFg .white

  result := result.writeString boxX (centerY - 2) "┌────────────────────┐" borderStyle
  result := result.writeString boxX (centerY - 1) "│     YOU WIN!       │" borderStyle
  result := result.writeString boxX centerY "│                    │" textStyle
  result := result.writeString boxX (centerY + 1) "│   Press R to play  │" textStyle
  result := result.writeString boxX (centerY + 2) "└────────────────────┘" borderStyle

  result

/-- Render game over overlay -/
def renderGameOverOverlay (buf : Buffer) (x y width height : Nat) : Buffer := Id.run do
  let mut result := buf

  let centerY := y + height / 2
  let boxWidth := 22
  let boxX := x + (width - boxWidth) / 2

  let borderStyle := Style.default.withFg .red |>.withModifier { bold := true }
  let textStyle := Style.default.withFg .white

  result := result.writeString boxX (centerY - 2) "┌────────────────────┐" borderStyle
  result := result.writeString boxX (centerY - 1) "│     GAME OVER      │" borderStyle
  result := result.writeString boxX centerY "│                    │" textStyle
  result := result.writeString boxX (centerY + 1) "│   Press R to play  │" textStyle
  result := result.writeString boxX (centerY + 2) "└────────────────────┘" borderStyle

  result

end Minefield.UI
