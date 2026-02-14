/-
  Vane.Render.Grid - GPU-accelerated terminal cell grid rendering

  Uses direct draw calls for all cell rendering.
-/

import Afferent
import Vane.Core.Cell
import Vane.Core.Style
import Vane.Core.Buffer
import Vane.Terminal.State
import Vane.Terminal.Cursor
import Vane.App.Selection

namespace Vane.Render.Grid

open Afferent
open Vane.Terminal
open Vane.App (SelectionRange)

/-- Convert Vane Color to Afferent Color -/
def vaneColorToAfferent (c : Vane.Color) (isForeground : Bool) : Afferent.Color :=
  let (r, g, b, a) := c.toRGBA isForeground
  Color.rgba r g b a

/-- Render parameters for the grid -/
structure RenderParams where
  font : Font
  cellWidth : Float
  cellHeight : Float
  paddingX : Float
  paddingY : Float
  defaultFg : Afferent.Color
  defaultBg : Afferent.Color
  cursorColor : Afferent.Color

/-- Calculate cell position on screen -/
def cellPosition (params : RenderParams) (col row : Nat) : Point :=
  ⟨params.paddingX + col.toFloat * params.cellWidth,
   params.paddingY + row.toFloat * params.cellHeight⟩

/-! ## Background Rendering -/

/-- Render all cell backgrounds that need drawing.
    Only includes cells with non-default background or reverse video. -/
def renderBackgrounds (canvas : Canvas) (params : RenderParams) (buffer : Buffer)
    (width height : Nat) (rowFilter : Nat → Bool := fun _ => true) : IO Canvas := do
  let mut c := canvas
  for row in [0:height] do
    if rowFilter row then
      for col in [0:width] do
        let cell := buffer.get col row
        -- Only draw non-default backgrounds
        if cell.bg != .default || cell.modifier.reverse then
          let bgColor := if cell.modifier.reverse then
            vaneColorToAfferent cell.fg true
          else
            vaneColorToAfferent cell.bg false
          let x := params.paddingX + col.toFloat * params.cellWidth
          let y := params.paddingY + row.toFloat * params.cellHeight
          let c' := c.setFillColor bgColor
          c ← c'.fillRectXYWH x y params.cellWidth params.cellHeight

  pure c

/-! ## Selection Highlight Rendering -/

/-- Selection highlight color (semi-transparent blue) -/
def selectionColor : Afferent.Color := Color.rgba 0.3 0.5 0.8 0.4

/-- Render selection highlights. -/
def renderSelection (canvas : Canvas) (params : RenderParams) (selection : SelectionRange)
    (width height : Nat) : IO Canvas := do
  let sel := selection.normalize
  let mut c := canvas

  for row in [sel.startRow : min (sel.endRow + 1) height] do
    let startCol := if row == sel.startRow then sel.startCol else 0
    let endCol := if row == sel.endRow then sel.endCol else width

    if startCol < endCol && startCol < width then
      let x := params.paddingX + startCol.toFloat * params.cellWidth
      let y := params.paddingY + row.toFloat * params.cellHeight
      let w := (min endCol width - startCol).toFloat * params.cellWidth
      let c' := c.setFillColor selectionColor
      c ← c'.fillRectXYWH x y w params.cellHeight

  pure c

/-! ## Text Rendering -/

/-- Render a single cell's foreground (character) -/
def renderCellForeground (canvas : Canvas) (params : RenderParams)
    (col row : Nat) (cell : Cell) : IO Canvas := do
  -- Skip empty or space characters
  if cell.width == 0 then
    pure canvas
  else if cell.char == ' ' && cell.combining.isEmpty then
    pure canvas
  else
    let fgColor := if cell.modifier.reverse then
      vaneColorToAfferent cell.bg false
    else if cell.modifier.hidden then
      vaneColorToAfferent cell.bg false  -- Same as background = invisible
    else
      vaneColorToAfferent cell.fg true

    let pos := cellPosition params col row
    -- Offset text slightly from top-left of cell
    let textPos := ⟨pos.x, pos.y + params.font.ascender⟩
    let text := cell.text
    if text.isEmpty then
      pure canvas
    else
      canvas.fillTextColor text textPos params.font fgColor

/-! ## Cursor Rendering -/

/-- Render the cursor -/
def renderCursor (canvas : Canvas) (params : RenderParams)
    (cursor : Cursor) (visible : Bool) : IO Canvas := do
  if !cursor.visible || !visible then
    pure canvas
  else
    let pos := cellPosition params cursor.col cursor.row
    let c := canvas.setFillColor params.cursorColor

    match cursor.style with
    | .block | .blinkBlock =>
      -- Full block cursor (filled rectangle)
      c.fillRectXYWH pos.x pos.y params.cellWidth params.cellHeight

    | .underline | .blinkUnderline =>
      -- Underline cursor (thin rectangle at bottom)
      let underlineHeight := params.cellHeight * 0.1
      let y := pos.y + params.cellHeight - underlineHeight
      c.fillRectXYWH pos.x y params.cellWidth underlineHeight

    | .bar | .blinkBar =>
      -- Vertical bar cursor (thin rectangle on left)
      let barWidth := params.cellWidth * 0.1
      c.fillRectXYWH pos.x pos.y barWidth params.cellHeight

/-! ## Main Render Functions -/

/-- Render the entire terminal grid using direct draw calls. -/
def render (canvas : Canvas) (params : RenderParams)
    (terminal : TerminalState) (cursorVisible : Bool)
    (selection : Option SelectionRange := none) : IO Canvas := do
  let buffer := terminal.currentBuffer

  -- Phase 1: Render backgrounds
  let mut c ← renderBackgrounds canvas params buffer terminal.width terminal.height

  -- Phase 1.5: Render selection highlight (after backgrounds, before text)
  match selection with
  | some sel =>
    if !sel.isEmpty then
      c ← renderSelection c params sel terminal.width terminal.height
  | none => pure ()

  -- Phase 2: Render all foreground characters
  for row in [0:terminal.height] do
    for col in [0:terminal.width] do
      let cell := buffer.get col row
      c ← renderCellForeground c params col row cell

  -- Phase 3: Render cursor
  c ← renderCursor c params terminal.cursor cursorVisible

  pure c

/-- Render only dirty rows using direct draw calls. -/
def renderDirty (canvas : Canvas) (params : RenderParams)
    (terminal : TerminalState) (cursorVisible : Bool)
    (selection : Option SelectionRange := none) : IO Canvas := do
  let buffer := terminal.currentBuffer

  -- Row filter: only include dirty rows
  let isDirty := fun row => terminal.dirtyRows[row]?.getD true

  -- Phase 1: Render backgrounds for dirty rows
  let mut c ← renderBackgrounds canvas params buffer terminal.width terminal.height isDirty

  -- Phase 1.5: Render selection highlight
  match selection with
  | some sel =>
    if !sel.isEmpty then
      c ← renderSelection c params sel terminal.width terminal.height
  | none => pure ()

  -- Phase 2: Render foreground for dirty rows only
  for row in [0:terminal.height] do
    if isDirty row then
      for col in [0:terminal.width] do
        let cell := buffer.get col row
        c ← renderCellForeground c params col row cell

  -- Phase 3: Always render cursor
  c ← renderCursor c params terminal.cursor cursorVisible

  pure c

/-! ## Legacy Single-Cell Rendering (for reference) -/

/-- Render a single cell's background. -/
def renderCellBackground (canvas : Canvas) (params : RenderParams)
    (col row : Nat) (cell : Cell) : IO Canvas := do
  let bgColor := if cell.modifier.reverse then
    vaneColorToAfferent cell.fg true
  else
    vaneColorToAfferent cell.bg false

  -- Only draw background if it's not the default
  if cell.bg != .default || cell.modifier.reverse then
    let pos := cellPosition params col row
    let c := canvas.setFillColor bgColor
    c.fillRectXYWH pos.x pos.y params.cellWidth params.cellHeight
  else
    pure canvas

end Vane.Render.Grid
