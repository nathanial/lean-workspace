/-
  Solitaire.Game.Init
  Game initialization and dealing
-/
import Solitaire.Game.State

namespace Solitaire.Game

open Solitaire.Core

/-- Create a new game with the given seed -/
def GameState.new (seed : UInt64) : GameState := Id.run do
  let rng := RNG.new seed
  let deck := standardDeck
  let (shuffled, rng') := shuffle deck rng

  -- Deal to 7 tableau piles:
  -- Pile 0: 1 card (face up)
  -- Pile 1: 2 cards (1 face down, 1 face up)
  -- ...
  -- Pile 6: 7 cards (6 face down, 1 face up)
  let mut tableaux : Array Tableau := #[]
  let mut cardIdx := 0

  for pileIdx in [0:7] do
    let mut cards : Array TableauCard := #[]
    for j in [0 : pileIdx + 1] do
      let faceUp := j == pileIdx  -- Only top card is face-up
      if h : cardIdx < shuffled.size then
        cards := cards.push { card := shuffled[cardIdx], faceUp }
        cardIdx := cardIdx + 1
    tableaux := tableaux.push cards

  -- Remaining 24 cards go to stock
  let mut stockCards : Array Card := #[]
  for i in [cardIdx : 52] do
    if h : i < shuffled.size then
      stockCards := stockCards.push shuffled[i]

  {
    stock := stockCards
    waste := #[]
    foundations := #[#[], #[], #[], #[]]
    tableaux
    cursor := .tableau ⟨0, by decide⟩ 0
    selection := none
    status := .playing
    moveCount := 0
    undoStack := #[]
    rng := rng'
  }

/-- Restart the game with a new seed -/
def GameState.restart (s : GameState) (seed : UInt64) : GameState :=
  GameState.new seed

end Solitaire.Game
