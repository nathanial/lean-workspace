/-
  Solitaire.Core.Piles
  Pile data structures and operations
-/
import Solitaire.Core.Types

namespace Solitaire.Core

/-- Stock pile (face-down cards to draw from) -/
abbrev Stock := Array Card

/-- Waste pile (face-up cards drawn from stock) -/
abbrev Waste := Array Card

/-- Foundation pile (one per suit, builds A to K) -/
abbrev Foundation := Array Card

namespace Foundation

def empty : Foundation := #[]

def topCard (f : Foundation) : Option Card :=
  if f.isEmpty then none else some f.back!

def canAccept (f : Foundation) (c : Card) : Bool :=
  Card.canStackOnFoundation f.topCard c

def add (f : Foundation) (c : Card) : Foundation :=
  f.push c

def remove (f : Foundation) : Foundation × Option Card :=
  if f.isEmpty then (f, none)
  else (f.pop, some f.back!)

end Foundation

/-- Tableau pile (cascading cards, some face-down) -/
abbrev Tableau := Array TableauCard

namespace Tableau

def empty : Tableau := #[]

/-- Get the visible (face-up) cards from top -/
def faceUpCards (t : Tableau) : Array Card :=
  -- Collect face-up cards from top backwards until we hit a face-down card
  let rec go (idx : Nat) (acc : Array Card) : Array Card :=
    if h : idx > 0 then
      let i := idx - 1
      if hi : i < t.size then
        let tc := t[i]
        if tc.faceUp then go i (acc.push tc.card)
        else acc
      else acc
    else acc
  termination_by idx
  (go t.size #[]).reverse

/-- Count of face-up cards -/
def faceUpCount (t : Tableau) : Nat :=
  t.foldl (fun n tc => if tc.faceUp then n + 1 else n) 0

/-- Get top card if any -/
def topCard (t : Tableau) : Option Card :=
  if t.isEmpty then none
  else some t.back!.card

/-- Check if a card can be placed on this tableau pile -/
def canAccept (t : Tableau) (c : Card) : Bool :=
  match t.topCard with
  | none => c.rank == .king  -- Empty tableau only accepts Kings
  | some top => Card.canStackOnTableau top c

/-- Push a face-up card onto the tableau -/
def pushCard (t : Tableau) (c : Card) : Tableau :=
  t.push { card := c, faceUp := true }

/-- Push multiple face-up cards onto the tableau -/
def pushCards (t : Tableau) (cards : Array Card) : Tableau := Id.run do
  let mut result := t
  for c in cards do
    result := result.push { card := c, faceUp := true }
  result

/-- Pop the top card -/
def popCard (t : Tableau) : Tableau × Option Card :=
  if t.isEmpty then (t, none)
  else (t.pop, some t.back!.card)

/-- Pop n cards from top, returning them in order (bottom to top of moved stack) -/
def popCards (t : Tableau) (n : Nat) : Tableau × Array Card := Id.run do
  let mut tableau := t
  let mut cards : Array Card := #[]
  for _ in [0 : n] do
    if tableau.isEmpty then
      return (tableau, cards.reverse)
    cards := cards.push tableau.back!.card
    tableau := tableau.pop
  (tableau, cards.reverse)

/-- Flip top card face-up if it's face-down -/
def flipTop (t : Tableau) : Tableau :=
  if t.isEmpty then t
  else
    let top := t.back!
    if top.faceUp then t
    else t.pop.push { top with faceUp := true }

/-- Check if top card is face-down -/
def topIsFaceDown (t : Tableau) : Bool :=
  if t.isEmpty then false
  else !t.back!.faceUp

end Tableau

end Solitaire.Core
