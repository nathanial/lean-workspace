/-
  Solitaire.Game.Logic
  Move execution and game mechanics
-/
import Solitaire.Game.Validation

namespace Solitaire.Game

open Solitaire.Core

/-- Save current state for undo -/
def GameState.saveUndo (s : GameState) : GameState :=
  let undoState : UndoState := {
    stock := s.stock
    waste := s.waste
    foundations := s.foundations
    tableaux := s.tableaux
  }
  { s with undoStack := s.undoStack.push undoState }

/-- Undo the last move -/
def GameState.undo (s : GameState) : GameState :=
  match s.undoStack.back? with
  | none => s
  | some prev =>
    { s with
      stock := prev.stock
      waste := prev.waste
      foundations := prev.foundations
      tableaux := prev.tableaux
      undoStack := s.undoStack.pop
      moveCount := s.moveCount
    }

/-- Update status if game is won -/
def GameState.updateStatus (s : GameState) : GameState :=
  if s.checkWin then { s with status := .won }
  else s

/-- Draw a card from stock to waste -/
def GameState.draw (s : GameState) : GameState :=
  if !canDraw s then s
  else
    let s := s.saveUndo
    let card := s.stock.back!
    { s with
      stock := s.stock.pop
      waste := s.waste.push card
      moveCount := s.moveCount + 1
    }

/-- Reset stock from waste (flip waste over) -/
def GameState.resetStock (s : GameState) : GameState :=
  if !canResetStock s then s
  else
    let s := s.saveUndo
    { s with
      stock := s.waste.reverse
      waste := #[]
      moveCount := s.moveCount + 1
    }

/-- Move waste top card to tableau -/
def GameState.wasteToTableau (s : GameState) (idx : Fin 7) : GameState :=
  if !canWasteToTableau s idx then s
  else
    let s := s.saveUndo
    let card := s.waste.back!
    let tab := s.tableaux[idx.val]!
    let newTab := tab.pushCard card
    { s with
      waste := s.waste.pop
      tableaux := s.tableaux.set! idx.val newTab
      moveCount := s.moveCount + 1
    }

/-- Move waste top card to foundation -/
def GameState.wasteToFoundation (s : GameState) (idx : Fin 4) : GameState :=
  if !canWasteToFoundation s idx then s
  else
    let s := s.saveUndo
    let card := s.waste.back!
    let found := s.foundations[idx.val]!
    let newFound := found.push card
    let newState := { s with
      waste := s.waste.pop
      foundations := s.foundations.set! idx.val newFound
      moveCount := s.moveCount + 1
    }
    newState.updateStatus

/-- Move cards from one tableau to another -/
def GameState.tableauToTableau (s : GameState) (fromIdx toIdx : Fin 7) (cardCount : Nat) : GameState :=
  if !canTableauToTableau s fromIdx toIdx cardCount then s
  else
    let s := s.saveUndo
    let fromTab := s.tableaux[fromIdx.val]!
    let (newFromTab, cards) := fromTab.popCards cardCount
    let newFromTab := newFromTab.flipTop
    let toTab := s.tableaux[toIdx.val]!
    let newToTab := toTab.pushCards cards
    let tableaux := s.tableaux.set! fromIdx.val newFromTab
    let tableaux := tableaux.set! toIdx.val newToTab
    { s with
      tableaux
      moveCount := s.moveCount + 1
    }

/-- Move tableau top card to foundation -/
def GameState.tableauToFoundation (s : GameState) (tableauIdx : Fin 7) (foundIdx : Fin 4) : GameState :=
  if !canTableauToFoundation s tableauIdx foundIdx then s
  else
    let s := s.saveUndo
    let tab := s.tableaux[tableauIdx.val]!
    let (newTab, cardOpt) := tab.popCard
    match cardOpt with
    | none => s
    | some card =>
      let newTab := newTab.flipTop
      let found := s.foundations[foundIdx.val]!
      let newFound := found.push card
      let tableaux := s.tableaux.set! tableauIdx.val newTab
      let foundations := s.foundations.set! foundIdx.val newFound
      let newState := { s with tableaux, foundations, moveCount := s.moveCount + 1 }
      newState.updateStatus

/-- Move foundation top card to tableau (uncommon but allowed) -/
def GameState.foundationToTableau (s : GameState) (foundIdx : Fin 4) (tableauIdx : Fin 7) : GameState :=
  if !canFoundationToTableau s foundIdx tableauIdx then s
  else
    let s := s.saveUndo
    let found := s.foundations[foundIdx.val]!
    if found.isEmpty then s
    else
      let card := found.back!
      let newFound := found.pop
      let tab := s.tableaux[tableauIdx.val]!
      let newTab := tab.pushCard card
      let foundations := s.foundations.set! foundIdx.val newFound
      let tableaux := s.tableaux.set! tableauIdx.val newTab
      { s with foundations, tableaux, moveCount := s.moveCount + 1 }

/-- Auto-move card to foundation if possible -/
def GameState.autoFoundation (s : GameState) (pile : PileId) : GameState :=
  match pile with
  | .waste =>
    match findFoundationForWaste s with
    | none => s
    | some foundIdx => s.wasteToFoundation foundIdx
  | .tableau idx =>
    match findFoundationForTableau s idx with
    | none => s
    | some foundIdx => s.tableauToFoundation idx foundIdx
  | _ => s

end Solitaire.Game
