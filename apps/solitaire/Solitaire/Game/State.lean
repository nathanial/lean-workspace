/-
  Solitaire.Game.State
  Game state structures
-/
import Solitaire.Core

namespace Solitaire.Game

open Solitaire.Core

/-- Game status -/
inductive GameStatus where
  | playing
  | won
  deriving Repr, BEq, Inhabited

/-- A move that can be undone -/
inductive Move where
  | draw                                        -- Drew card from stock
  | resetStock                                  -- Recycled waste to stock
  | wasteToTableau (tableauIdx : Fin 7)
  | wasteToFoundation (foundIdx : Fin 4)
  | tableauToTableau (fromIdx toIdx : Fin 7) (cardCount : Nat) (flipped : Bool)
  | tableauToFoundation (tableauIdx : Fin 7) (foundIdx : Fin 4) (flipped : Bool)
  | foundationToTableau (foundIdx : Fin 4) (tableauIdx : Fin 7)
  deriving Repr, BEq

/-- Snapshot of game state for undo -/
structure UndoState where
  stock : Stock
  waste : Waste
  foundations : Array Foundation
  tableaux : Array Tableau
  deriving Repr

/-- Complete game state -/
structure GameState where
  stock : Stock
  waste : Waste
  foundations : Array Foundation  -- Size 4: spades, hearts, diamonds, clubs
  tableaux : Array Tableau        -- Size 7
  cursor : CursorPos
  selection : Option Selection
  status : GameStatus
  moveCount : Nat
  undoStack : Array UndoState
  rng : RNG
  deriving Repr, Inhabited

namespace GameState

/-- Check if the game is won -/
def isWon (s : GameState) : Bool :=
  s.status == .won

/-- Check if the game is still in progress -/
def isPlaying (s : GameState) : Bool :=
  s.status == .playing

/-- Total cards in all foundations -/
def foundationCardCount (s : GameState) : Nat :=
  s.foundations.foldl (fun acc f => acc + f.size) 0

/-- Check win condition (all 52 cards in foundations) -/
def checkWin (s : GameState) : Bool :=
  s.foundationCardCount == 52

end GameState

end Solitaire.Game
