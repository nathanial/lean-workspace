/-
  Solitaire.Game.Validation
  Move validation rules for Klondike Solitaire
-/
import Solitaire.Game.State

namespace Solitaire.Game

open Solitaire.Core

/-- Check if we can draw from stock -/
def canDraw (s : GameState) : Bool :=
  !s.stock.isEmpty

/-- Check if we can reset stock from waste -/
def canResetStock (s : GameState) : Bool :=
  s.stock.isEmpty && !s.waste.isEmpty

/-- Check if waste top card can go to a foundation -/
def canWasteToFoundation (s : GameState) (foundIdx : Fin 4) : Bool :=
  match s.waste.back? with
  | none => false
  | some card =>
    if h : foundIdx.val < s.foundations.size then
      s.foundations[foundIdx.val].canAccept card
    else false

/-- Check if waste top card can go to a tableau -/
def canWasteToTableau (s : GameState) (tableauIdx : Fin 7) : Bool :=
  match s.waste.back? with
  | none => false
  | some card =>
    if h : tableauIdx.val < s.tableaux.size then
      s.tableaux[tableauIdx.val].canAccept card
    else false

/-- Check if cards from one tableau can move to another -/
def canTableauToTableau (s : GameState) (fromIdx toIdx : Fin 7) (cardCount : Nat) : Bool :=
  if fromIdx == toIdx then false
  else if h₁ : fromIdx.val < s.tableaux.size then
    if h₂ : toIdx.val < s.tableaux.size then
      let fromTab := s.tableaux[fromIdx.val]
      let faceUp := fromTab.faceUpCards
      if cardCount > faceUp.size || cardCount == 0 then false
      else
        -- The bottom card of the moving stack (first in the face-up array from bottom)
        let bottomIdx := faceUp.size - cardCount
        if h₃ : bottomIdx < faceUp.size then
          let movingBottom := faceUp[bottomIdx]
          s.tableaux[toIdx.val].canAccept movingBottom
        else false
    else false
  else false

/-- Check if tableau top card can go to foundation -/
def canTableauToFoundation (s : GameState) (tableauIdx : Fin 7) (foundIdx : Fin 4) : Bool :=
  if h₁ : tableauIdx.val < s.tableaux.size then
    if h₂ : foundIdx.val < s.foundations.size then
      match s.tableaux[tableauIdx.val].topCard with
      | none => false
      | some card => s.foundations[foundIdx.val].canAccept card
    else false
  else false

/-- Check if foundation top card can go to tableau -/
def canFoundationToTableau (s : GameState) (foundIdx : Fin 4) (tableauIdx : Fin 7) : Bool :=
  if h₁ : foundIdx.val < s.foundations.size then
    if h₂ : tableauIdx.val < s.tableaux.size then
      match s.foundations[foundIdx.val].topCard with
      | none => false
      | some card => s.tableaux[tableauIdx.val].canAccept card
    else false
  else false

/-- Find which foundation can accept a card (if any) -/
def findFoundationForCard (s : GameState) (c : Card) : Option (Fin 4) :=
  if s.foundations[0]!.canAccept c then some ⟨0, by decide⟩
  else if s.foundations[1]!.canAccept c then some ⟨1, by decide⟩
  else if s.foundations[2]!.canAccept c then some ⟨2, by decide⟩
  else if s.foundations[3]!.canAccept c then some ⟨3, by decide⟩
  else none

/-- Auto-find foundation for waste card -/
def findFoundationForWaste (s : GameState) : Option (Fin 4) :=
  match s.waste.back? with
  | none => none
  | some card => findFoundationForCard s card

/-- Auto-find foundation for tableau top card -/
def findFoundationForTableau (s : GameState) (tableauIdx : Fin 7) : Option (Fin 4) :=
  if h : tableauIdx.val < s.tableaux.size then
    match s.tableaux[tableauIdx.val].topCard with
    | none => none
    | some card => findFoundationForCard s card
  else none

end Solitaire.Game
