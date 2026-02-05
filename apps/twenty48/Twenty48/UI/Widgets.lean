/-
  Twenty48.UI.Widgets
  Rendering widgets for the game
-/
import Twenty48.Core
import Twenty48.Game
import Terminus

namespace Twenty48.UI

open Twenty48.Core
open Twenty48.Game
open Terminus

/-- Get the background color for a tile value (exponent) -/
def tileBackground : Nat → Color
  | 0 => .indexed 250    -- Empty: light gray
  | 1 => .indexed 223    -- 2: cream
  | 2 => .indexed 222    -- 4: tan
  | 3 => .indexed 208    -- 8: orange
  | 4 => .indexed 202    -- 16: dark orange
  | 5 => .indexed 196    -- 32: red
  | 6 => .indexed 160    -- 64: dark red
  | 7 => .indexed 226    -- 128: yellow
  | 8 => .indexed 220    -- 256: gold
  | 9 => .indexed 214    -- 512: orange-gold
  | 10 => .indexed 208   -- 1024: bright orange
  | 11 => .indexed 196   -- 2048: bright red
  | _ => .indexed 201    -- 4096+: magenta

/-- Get foreground (text) color for a tile -/
def tileForeground : Nat → Color
  | 0 => .indexed 250    -- Empty: same as background (invisible)
  | 1 => .indexed 236    -- 2: dark
  | 2 => .indexed 236    -- 4: dark
  | _ => .white          -- 8+: white

/-- Tile cell width (characters) -/
def tileCellWidth : Nat := 6

/-- Tile cell height (lines) -/
def tileCellHeight : Nat := 3

/-- Format a tile value for display -/
def formatTileValue (exp : Nat) : String :=
  if exp == 0 then "    "
  else
    let value := 2 ^ exp
    let s := toString value
    -- Center the value in 4 characters
    let padding := (4 - s.length) / 2
    let leftPad := String.ofList (List.replicate padding ' ')
    let rightPad := String.ofList (List.replicate (4 - s.length - padding) ' ')
    leftPad ++ s ++ rightPad

/-- Get merge animation style based on timer -/
def mergeStyle (normalBg : Color) (timer : Nat) : Color × Color :=
  match timer with
  | 6 | 5 => (.indexed 231, .black)    -- Bright white glow
  | 4 | 3 => (.white, .black)          -- White flash
  | _ => (normalBg, .default)          -- Settle to normal

/-- Get spawn animation style based on timer -/
def spawnStyleModifier (timer : Nat) : Style → Style
  | style => match timer with
    | 5 | 4 => style.withModifier { dim := true }     -- Dim start
    | 3 => style.withBg (.indexed 231)                -- Flash bright
    | _ => style                                       -- Normal

/-- Render a single tile at screen position with style overrides -/
def renderTileWithStyle (buf : Buffer) (screenX screenY : Nat) (tile : Tile)
    (bgOverride : Option Color := none) (fgOverride : Option Color := none)
    (styleModifier : Style → Style := id) : Buffer := Id.run do
  let exp := tile.getD 0
  let normalBg := tileBackground exp
  let normalFg := tileForeground exp
  let bg := bgOverride.getD normalBg
  let fg := fgOverride.getD normalFg

  let baseStyle := Style.default.withFg fg |>.withBg bg
  let style := styleModifier baseStyle

  let mut result := buf

  -- Render 3 rows of the tile
  let topRow := "██████"
  let valueStr := formatTileValue exp
  let midRow := "█" ++ valueStr ++ "█"
  let botRow := "██████"

  result := result.writeString screenX screenY topRow style
  result := result.writeString screenX (screenY + 1) midRow style
  result := result.writeString screenX (screenY + 2) botRow style

  result

/-- Render a single tile at screen position (simple version) -/
def renderTile (buf : Buffer) (screenX screenY : Nat) (tile : Tile)
    (flash : Bool := false) (isNew : Bool := false) : Buffer := Id.run do
  let exp := tile.getD 0
  let bg := if flash then .white else tileBackground exp
  let fg := if flash then .black else tileForeground exp

  let style := Style.default.withFg fg |>.withBg bg

  let mut result := buf

  -- Render 3 rows of the tile
  let topRow := "██████"
  let valueStr := formatTileValue exp
  let midRow := "█" ++ valueStr ++ "█"
  let botRow := "██████"

  -- For new tiles, use a smaller representation initially
  if isNew then
    let newStyle := style.withModifier { bold := true }
    result := result.writeString screenX screenY topRow newStyle
    result := result.writeString screenX (screenY + 1) midRow newStyle
    result := result.writeString screenX (screenY + 2) botRow newStyle
  else
    result := result.writeString screenX screenY topRow style
    result := result.writeString screenX (screenY + 1) midRow style
    result := result.writeString screenX (screenY + 2) botRow style

  result

/-- Interpolate screen position during slide animation -/
def interpolatePosition (fromPos toPos : Point) (timer total : Nat)
    (startX startY : Nat) : Nat × Nat :=
  -- Timer counts down, so progress goes from 0 to 1
  let progress := total - timer
  let fromScreenX := startX + 1 + fromPos.x * tileCellWidth
  let fromScreenY := startY + 1 + fromPos.y * tileCellHeight
  let toScreenX := startX + 1 + toPos.x * tileCellWidth
  let toScreenY := startY + 1 + toPos.y * tileCellHeight

  if progress >= total then
    (toScreenX, toScreenY)
  else
    -- Linear interpolation
    let dx := if toScreenX >= fromScreenX
              then (toScreenX - fromScreenX) * progress / total
              else 0  -- Handle negative case separately
    let dy := if toScreenY >= fromScreenY
              then (toScreenY - fromScreenY) * progress / total
              else 0
    let negDx := if fromScreenX > toScreenX
                 then (fromScreenX - toScreenX) * progress / total
                 else 0
    let negDy := if fromScreenY > toScreenY
                 then (fromScreenY - toScreenY) * progress / total
                 else 0
    (fromScreenX + dx - negDx, fromScreenY + dy - negDy)

/-- Render the game grid with animation support -/
def renderGrid (buf : Buffer) (state : GameState) (startX startY : Nat) : Buffer := Id.run do
  let mut result := buf

  -- Grid background
  let bgStyle := Style.default.withBg (.indexed 187)  -- Tan background

  -- Draw background for entire grid area
  let gridWidth := gridSize * tileCellWidth + 2
  let gridHeight := gridSize * tileCellHeight + 2
  let bgChar := " "

  for dy in List.range gridHeight do
    for dx in List.range gridWidth do
      result := result.writeString (startX + dx) (startY + dy) bgChar bgStyle

  -- Draw border
  let borderStyle := (Style.default.withFg (.indexed 94)).withBg (.indexed 187)
  let hLine := String.ofList (List.replicate (gridWidth - 2) '─')
  result := result.writeString startX startY ("┌" ++ hLine ++ "┐") borderStyle
  result := result.writeString startX (startY + gridHeight - 1) ("└" ++ hLine ++ "┘") borderStyle

  for dy in [1:gridHeight - 1] do
    result := result.writeString startX (startY + dy) "│" borderStyle
    result := result.writeString (startX + gridWidth - 1) (startY + dy) "│" borderStyle

  -- Render based on animation phase
  match state.anim.phase with
  | .sliding =>
    -- Draw tiles at interpolated positions
    for movement in state.anim.tileMovements do
      let (screenX, screenY) := interpolatePosition
        movement.fromPos movement.toPos state.anim.timer 4 startX startY
      result := renderTile result screenX screenY movement.tile

  | .merging =>
    -- Draw all tiles, with merge effect on merging cells
    for y in List.range gridSize do
      for x in List.range gridSize do
        let tile := state.grid.get x y
        let tileX := startX + 1 + x * tileCellWidth
        let tileY := startY + 1 + y * tileCellHeight

        let isMerging := state.anim.mergingCells.any fun p => p.x == x && p.y == y
        if isMerging then
          let (bg, fg) := mergeStyle (tileBackground (tile.getD 0)) state.anim.timer
          result := renderTileWithStyle result tileX tileY tile (some bg) (some fg)
        else
          result := renderTile result tileX tileY tile

  | .spawning =>
    -- Draw all tiles, with spawn effect on new tile
    for y in List.range gridSize do
      for x in List.range gridSize do
        let tile := state.grid.get x y
        let tileX := startX + 1 + x * tileCellWidth
        let tileY := startY + 1 + y * tileCellHeight

        let isSpawning := match state.anim.newTilePos with
          | some p => p.x == x && p.y == y
          | none => false

        if isSpawning then
          result := renderTileWithStyle result tileX tileY tile none none
            (spawnStyleModifier state.anim.timer)
        else
          result := renderTile result tileX tileY tile

  | .idle =>
    -- Normal rendering, no animation effects
    for y in List.range gridSize do
      for x in List.range gridSize do
        let tile := state.grid.get x y
        let tileX := startX + 1 + x * tileCellWidth
        let tileY := startY + 1 + y * tileCellHeight
        result := renderTile result tileX tileY tile

  result

/-- Render score display -/
def renderScore (buf : Buffer) (state : GameState) (x y : Nat) : Buffer := Id.run do
  let mut result := buf
  let labelStyle := Style.default.withFg .white
  let valueStyle := Style.default.withFg .cyan |>.withModifier { bold := true }

  result := result.writeString x y "SCORE" labelStyle
  result := result.writeString x (y + 1) (toString state.score) valueStyle

  result := result.writeString (x + 10) y "BEST" labelStyle
  result := result.writeString (x + 10) (y + 1) (toString state.bestScore) valueStyle

  result

/-- Render controls help -/
def renderControls (buf : Buffer) (x y : Nat) : Buffer := Id.run do
  let mut result := buf
  let borderStyle := Style.default.withFg .white
  let keyStyle := Style.default.withFg .yellow
  let descStyle := Style.default.withFg .white

  result := result.writeString x y       "┌──────────────┐" borderStyle
  result := result.writeString x (y + 1) "│   CONTROLS   │" borderStyle
  result := result.writeString x (y + 2) "├──────────────┤" borderStyle

  let controls := [
    ("↑↓←→", "Move"),
    ("WASD", "Move"),
    ("U", "Undo"),
    ("R", "Restart"),
    ("Q", "Quit")
  ]

  for i in List.range controls.length do
    if h : i < controls.length then
      let (key, desc) := controls[i]
      let lineY := y + 3 + i
      result := result.writeString x lineY "│" borderStyle
      result := result.writeString (x + 2) lineY key keyStyle
      result := result.writeString (x + 8) lineY desc descStyle
      result := result.writeString (x + 15) lineY "│" borderStyle

  result := result.writeString x (y + 8) "└──────────────┘" borderStyle
  result

/-- Render title -/
def renderTitle (buf : Buffer) (x y : Nat) : Buffer :=
  let style := Style.default.withFg (.indexed 208) |>.withModifier { bold := true }
  buf.writeString x y "╔════════════════════╗" style
    |>.writeString x (y + 1) "║       2048         ║" style
    |>.writeString x (y + 2) "╚════════════════════╝" style

/-- Render game over overlay -/
def renderGameOver (buf : Buffer) (state : GameState) (centerX centerY : Nat) : Buffer := Id.run do
  let mut result := buf
  let borderStyle := Style.default.withFg .red |>.withModifier { bold := true }
  let textStyle := Style.default.withFg .white
  let scoreStyle := Style.default.withFg .yellow

  let boxWidth := 22
  let x := if centerX > boxWidth / 2 then centerX - boxWidth / 2 else 0

  result := result.writeString x (centerY - 2) "╔════════════════════╗" borderStyle
  result := result.writeString x (centerY - 1) "║     GAME OVER      ║" borderStyle
  result := result.writeString x centerY       "║                    ║" borderStyle

  let scoreText := s!"Score: {state.score}"
  let scoreX := x + 2 + (18 - scoreText.length) / 2
  result := result.writeString scoreX centerY scoreText scoreStyle

  result := result.writeString x (centerY + 1) "║  Press R to retry  ║" textStyle
  result := result.writeString x (centerY + 2) "╚════════════════════╝" borderStyle

  result

/-- Render win overlay -/
def renderWin (buf : Buffer) (centerX centerY : Nat) : Buffer := Id.run do
  let mut result := buf
  let borderStyle := Style.default.withFg .yellow |>.withModifier { bold := true }
  let textStyle := Style.default.withFg .white

  let boxWidth := 22
  let x := if centerX > boxWidth / 2 then centerX - boxWidth / 2 else 0

  result := result.writeString x (centerY - 2) "╔════════════════════╗" borderStyle
  result := result.writeString x (centerY - 1) "║     YOU WIN!       ║" borderStyle
  result := result.writeString x centerY       "║     2048!          ║" borderStyle
  result := result.writeString x (centerY + 1) "║ Press C to continue║" textStyle
  result := result.writeString x (centerY + 2) "╚════════════════════╝" borderStyle

  result

end Twenty48.UI
