/-
  Solitaire.Core.Deck
  Deck creation and shuffling
-/
import Solitaire.Core.Types

namespace Solitaire.Core

/-- Simple RNG using LCG (Linear Congruential Generator) -/
structure RNG where
  state : UInt64
  deriving Repr, Inhabited

def RNG.new (seed : UInt64) : RNG := { state := seed }

def RNG.next (rng : RNG) : UInt64 × RNG :=
  let a : UInt64 := 6364136223846793005
  let c : UInt64 := 1442695040888963407
  let newState := a * rng.state + c
  (newState, { state := newState })

/-- Get a random number in range [0, bound) -/
def RNG.nextBounded (rng : RNG) (bound : Nat) : Nat × RNG :=
  let (val, rng') := rng.next
  (val.toNat % bound, rng')

/-- Fisher-Yates shuffle -/
def shuffle (arr : Array Card) (rng : RNG) : Array Card × RNG := Id.run do
  let mut cards := arr
  let mut r := rng
  for i in [0 : cards.size] do
    let remaining := cards.size - i
    if remaining > 1 then
      let (randIdx, r') := r.nextBounded remaining
      r := r'
      let j := i + randIdx
      if i < cards.size && j < cards.size then
        let vi := cards[i]!
        let vj := cards[j]!
        cards := cards.set! i vj
        cards := cards.set! j vi
  (cards, r)

/-- Create a standard 52-card deck -/
def standardDeck : Array Card := Id.run do
  let mut deck : Array Card := #[]
  for suit in Suit.all do
    for rank in Rank.all do
      deck := deck.push { suit, rank }
  deck

end Solitaire.Core
