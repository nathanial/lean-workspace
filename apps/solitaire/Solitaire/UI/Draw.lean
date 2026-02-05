/-
  Solitaire.UI.Draw
  Main drawing function for the game
-/
import Solitaire.UI.Widgets

namespace Solitaire.UI

open Solitaire.Core
open Solitaire.Game
open Terminus

/-- Layout constants -/
def tableauSpacing : Nat := 5  -- Space between tableau columns
def topRowY : Nat := 2         -- Y position of stock/waste/foundations
def tableauY : Nat := 5        -- Y position of tableau piles

/-- Calculate the X position for a tableau pile (0-6) -/
def tableauX (baseX : Nat) (idx : Nat) : Nat :=
  baseX + idx * tableauSpacing

/-- Get cursor card index for a tableau pile -/
def getCursorCardIdx (cursor : CursorPos) (tableauIdx : Fin 7) : Option Nat :=
  match cursor with
  | .tableau idx cardIdx => if idx == tableauIdx then some cardIdx else none
  | _ => none

/-- Get selected card count for a pile -/
def getSelectedCount (selection : Option Selection) (pile : PileId) : Nat :=
  match selection with
  | some sel => if sel.pile == pile then sel.cardCount else 0
  | none => 0

/-- Main draw function -/
def draw (frame : Frame) (state : GameState) : Frame := Id.run do
  let area := frame.area
  let mut buf := frame.buffer

  -- Clear with default background
  for y in [0 : area.height] do
    for x in [0 : area.width] do
      buf := buf.set x y Cell.empty

  -- Calculate centered layout
  let gameWidth := 7 * tableauSpacing  -- Width for 7 tableau piles
  let baseX := if area.width > gameWidth then (area.width - gameWidth) / 2 else 1

  -- Render title
  buf := renderTitle buf baseX 0

  -- Render move count
  buf := renderMoveCount buf (baseX + 25) 0 state.moveCount

  -- Render stock
  let stockHighlighted := state.cursor == .stock
  let stockSelected := getSelectedCount state.selection .stock > 0
  buf := renderStock buf baseX topRowY state.stock (stockHighlighted || stockSelected)

  -- Render waste
  let wasteHighlighted := state.cursor == .waste
  let wasteSelected := getSelectedCount state.selection .waste > 0
  buf := renderWaste buf (baseX + 5) topRowY state.waste wasteHighlighted wasteSelected

  -- Render foundations (right side)
  let foundationBaseX := baseX + 15
  for i in [0:4] do
    let fidx : Fin 4 := if h : i < 4 then ⟨i, h⟩ else ⟨0, by decide⟩
    let highlighted := match state.cursor with
      | .foundation idx => idx == fidx
      | _ => false
    let selected := match state.selection with
      | some sel => sel.pile == .foundation fidx
      | none => false
    let suit := match i with
      | 0 => Suit.spades
      | 1 => Suit.hearts
      | 2 => Suit.diamonds
      | _ => Suit.clubs
    buf := renderFoundation buf (foundationBaseX + i * 4) topRowY
      state.foundations[i]! suit highlighted selected

  -- Render tableau pile labels
  let labelStyle := Style.default.withFg (.indexed 240)
  for i in [0:7] do
    buf := buf.writeString (tableauX baseX i) (tableauY - 1) (toString (i + 1)) labelStyle

  -- Render tableau piles
  for i in [0:7] do
    let tidx : Fin 7 := if h : i < 7 then ⟨i, h⟩ else ⟨0, by decide⟩
    let cursorIdx := getCursorCardIdx state.cursor tidx
    let selectedCount := getSelectedCount state.selection (.tableau tidx)
    buf := renderTableau buf (tableauX baseX i) tableauY
      state.tableaux[i]! cursorIdx selectedCount

  -- Calculate max tableau height for controls placement
  let maxTableauHeight := state.tableaux.foldl (fun acc t => max acc t.size) 0
  let controlsY := tableauY + maxTableauHeight + 2

  -- Render selection indicator if something is selected
  match state.selection with
  | some sel => buf := renderSelectionIndicator buf baseX (controlsY - 1) sel
  | none => pure ()

  -- Render controls help
  buf := renderControls buf baseX controlsY

  -- Render win overlay if game is won
  if state.status == .won then
    let centerX := area.width / 2
    let centerY := area.height / 2
    buf := renderWinOverlay buf centerX centerY state.moveCount

  { frame with buffer := buf }

end Solitaire.UI
