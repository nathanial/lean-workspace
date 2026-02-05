/-
  Solitaire.UI.Widgets
  Card and pile rendering widgets
-/
import Solitaire.Game
import Terminus

namespace Solitaire.UI

open Solitaire.Core
open Solitaire.Game
open Terminus

/-- Card display width in characters -/
def cardWidth : Nat := 4

/-- Card display height in lines -/
def cardHeight : Nat := 1

/-- Get color for a card's suit -/
def suitColor (s : Suit) : Color :=
  if s.isRed then .red else .white

/-- Render a face-up card -/
def renderCard (buf : Buffer) (x y : Nat) (card : Card)
    (highlighted : Bool := false) (selected : Bool := false) : Buffer := Id.run do
  let display := card.display
  -- Pad to 3 chars (for "10♥" vs "A♠")
  let padded := if display.length < 3 then display ++ " " else display

  let fg := suitColor card.suit
  let bg := if selected then .indexed 236
            else if highlighted then .indexed 240
            else .default
  let style := Style.default.withFg fg |>.withBg bg

  buf.writeString x y padded style

/-- Render a face-down card -/
def renderFaceDown (buf : Buffer) (x y : Nat)
    (highlighted : Bool := false) : Buffer :=
  let bg := if highlighted then .indexed 240 else .indexed 17
  let style := Style.default.withFg (.indexed 244) |>.withBg bg
  buf.writeString x y "░░░" style

/-- Render an empty pile slot -/
def renderEmptySlot (buf : Buffer) (x y : Nat) (label : String)
    (highlighted : Bool := false) : Buffer :=
  let fg := if highlighted then .white else .indexed 240
  let style := Style.default.withFg fg
  buf.writeString x y label style

/-- Render the stock pile -/
def renderStock (buf : Buffer) (x y : Nat) (stock : Stock)
    (highlighted : Bool := false) : Buffer :=
  if stock.isEmpty then
    renderEmptySlot buf x y "[S]" highlighted
  else
    -- Show card count and face-down card
    let countStr := toString stock.size
    let padded := if countStr.length == 1 then " " ++ countStr else countStr
    let bg := if highlighted then .indexed 240 else .indexed 17
    let style := Style.default.withFg (.indexed 244) |>.withBg bg
    buf.writeString x y ("░" ++ padded) style

/-- Render the waste pile -/
def renderWaste (buf : Buffer) (x y : Nat) (waste : Waste)
    (highlighted : Bool := false) (selected : Bool := false) : Buffer :=
  match waste.back? with
  | none => renderEmptySlot buf x y "[W]" highlighted
  | some card => renderCard buf x y card highlighted selected

/-- Render a foundation pile -/
def renderFoundation (buf : Buffer) (x y : Nat) (found : Foundation) (suit : Suit)
    (highlighted : Bool := false) (selected : Bool := false) : Buffer :=
  match found.topCard with
  | none =>
    -- Show suit symbol as placeholder
    let fg := if highlighted then (suitColor suit) else .indexed 240
    let style := Style.default.withFg fg
    buf.writeString x y ("[" ++ suit.symbol ++ "]") style
  | some card =>
    renderCard buf x y card highlighted selected

/-- Render a tableau pile -/
def renderTableau (buf : Buffer) (x y : Nat) (tableau : Tableau)
    (cursorCardIdx : Option Nat := none) (selectedCount : Nat := 0) : Buffer := Id.run do
  let mut result := buf

  if tableau.isEmpty then
    let highlighted := cursorCardIdx.isSome
    return renderEmptySlot result x y "[ ]" highlighted

  -- Calculate which cards are selected (from top)
  let faceUpCount := tableau.faceUpCount

  for i in [0 : tableau.size] do
    if h : i < tableau.size then
      let tc := tableau[i]
      let rowY := y + i

      -- Is this card highlighted by cursor?
      let cardIdxFromTop := tableau.size - 1 - i
      let isHighlighted := match cursorCardIdx with
        | some idx => cardIdxFromTop == idx
        | none => false

      -- Is this card part of selection?
      let isSelected := selectedCount > 0 && cardIdxFromTop < selectedCount

      if tc.faceUp then
        result := renderCard result x rowY tc.card isHighlighted isSelected
      else
        result := renderFaceDown result x rowY isHighlighted

  result

/-- Render title bar -/
def renderTitle (buf : Buffer) (x y : Nat) : Buffer :=
  let style := Style.default.withFg .cyan |>.withModifier { bold := true }
  buf.writeString x y "KLONDIKE SOLITAIRE" style

/-- Render move counter -/
def renderMoveCount (buf : Buffer) (x y : Nat) (moves : Nat) : Buffer :=
  let labelStyle := Style.default.withFg .white
  let valueStyle := Style.default.withFg .yellow
  buf.writeString x y "Moves: " labelStyle
    |>.writeString (x + 7) y (toString moves) valueStyle

/-- Render controls help line -/
def renderControls (buf : Buffer) (x y : Nat) : Buffer :=
  let keyStyle := Style.default.withFg .yellow
  let descStyle := Style.default.withFg .white
  let sepStyle := Style.default.withFg (.indexed 240)

  buf.writeString x y "Arrows" keyStyle
    |>.writeString (x + 6) y ":" sepStyle
    |>.writeString (x + 7) y "Move" descStyle
    |>.writeString (x + 12) y "Enter" keyStyle
    |>.writeString (x + 17) y ":" sepStyle
    |>.writeString (x + 18) y "Select" descStyle
    |>.writeString (x + 25) y "s" keyStyle
    |>.writeString (x + 26) y ":" sepStyle
    |>.writeString (x + 27) y "Draw" descStyle
    |>.writeString (x + 32) y "u" keyStyle
    |>.writeString (x + 33) y ":" sepStyle
    |>.writeString (x + 34) y "Undo" descStyle
    |>.writeString (x + 39) y "r" keyStyle
    |>.writeString (x + 40) y ":" sepStyle
    |>.writeString (x + 41) y "New" descStyle
    |>.writeString (x + 45) y "q" keyStyle
    |>.writeString (x + 46) y ":" sepStyle
    |>.writeString (x + 47) y "Quit" descStyle

/-- Render win overlay -/
def renderWinOverlay (buf : Buffer) (centerX centerY : Nat) (moves : Nat) : Buffer := Id.run do
  let mut result := buf
  let borderStyle := Style.default.withFg .green |>.withModifier { bold := true }
  let textStyle := Style.default.withFg .white
  let scoreStyle := Style.default.withFg .yellow

  let boxWidth := 24
  let x := if centerX > boxWidth / 2 then centerX - boxWidth / 2 else 0

  result := result.writeString x (centerY - 2) "╔══════════════════════╗" borderStyle
  result := result.writeString x (centerY - 1) "║      YOU WIN!        ║" borderStyle
  result := result.writeString x centerY       "║                      ║" borderStyle

  let moveText := s!"Moves: {moves}"
  let moveX := x + 2 + (20 - moveText.length) / 2
  result := result.writeString moveX centerY moveText scoreStyle

  result := result.writeString x (centerY + 1) "║  Press R for new game║" textStyle
  result := result.writeString x (centerY + 2) "╚══════════════════════╝" borderStyle

  result

/-- Render selection indicator -/
def renderSelectionIndicator (buf : Buffer) (x y : Nat) (sel : Selection) : Buffer :=
  let style := Style.default.withFg .magenta |>.withModifier { bold := true }
  let text := match sel.pile with
    | .waste => "Selected: Waste"
    | .tableau idx => s!"Selected: T{idx.val + 1} ({sel.cardCount} card{if sel.cardCount > 1 then "s" else ""})"
    | .foundation idx => s!"Selected: F{idx.val + 1}"
    | .stock => "Selected: Stock"
  buf.writeString x y text style

end Solitaire.UI
