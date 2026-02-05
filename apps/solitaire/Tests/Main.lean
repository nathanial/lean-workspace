/-
  Solitaire Tests
-/
import Crucible
import Solitaire

namespace Solitaire.Tests

open Crucible
open Solitaire.Core
open Solitaire.Game

testSuite "Solitaire Tests"

-- Deck Tests

test "Standard deck has 52 cards" := do
  standardDeck.size ≡ 52

test "Shuffle preserves all cards" := do
  let deck := standardDeck
  let rng := RNG.new 12345
  let (shuffled, _) := shuffle deck rng
  shuffled.size ≡ 52

-- Card Stacking Tests

test "Black Jack can stack on Red Queen" := do
  let redQueen : Card := { suit := .hearts, rank := .queen }
  let blackJack : Card := { suit := .spades, rank := .jack }
  ensure (Card.canStackOnTableau redQueen blackJack) "Black Jack should stack on Red Queen"

test "Red Queen cannot stack on Black Jack" := do
  let redQueen : Card := { suit := .hearts, rank := .queen }
  let blackJack : Card := { suit := .spades, rank := .jack }
  ensure (!Card.canStackOnTableau blackJack redQueen) "Red Queen should not stack on Black Jack"

test "Ace can go on empty foundation" := do
  let aceSpades : Card := { suit := .spades, rank := .ace }
  ensure (Card.canStackOnFoundation none aceSpades) "Ace should go on empty foundation"

test "Two cannot go on empty foundation" := do
  let twoSpades : Card := { suit := .spades, rank := .two }
  ensure (!Card.canStackOnFoundation none twoSpades) "Two should not go on empty foundation"

test "Two of spades on Ace of spades" := do
  let aceSpades : Card := { suit := .spades, rank := .ace }
  let twoSpades : Card := { suit := .spades, rank := .two }
  ensure (Card.canStackOnFoundation (some aceSpades) twoSpades) "Two of spades should go on Ace of spades"

test "Two of hearts cannot go on Ace of spades" := do
  let aceSpades : Card := { suit := .spades, rank := .ace }
  let twoHearts : Card := { suit := .hearts, rank := .two }
  ensure (!Card.canStackOnFoundation (some aceSpades) twoHearts) "Two of hearts should not go on Ace of spades"

-- Game Initialization Tests

test "Stock has 24 cards" := do
  let state := GameState.new 42
  state.stock.size ≡ 24

test "Waste starts empty" := do
  let state := GameState.new 42
  state.waste.size ≡ 0

test "Seven tableau piles" := do
  let state := GameState.new 42
  state.tableaux.size ≡ 7

test "Tableau pile sizes" := do
  let state := GameState.new 42
  state.tableaux[0]!.size ≡ 1
  state.tableaux[1]!.size ≡ 2
  state.tableaux[2]!.size ≡ 3
  state.tableaux[3]!.size ≡ 4
  state.tableaux[4]!.size ≡ 5
  state.tableaux[5]!.size ≡ 6
  state.tableaux[6]!.size ≡ 7

-- Draw Tests

test "Draw reduces stock by 1" := do
  let state := GameState.new 42
  let state2 := state.draw
  state2.stock.size ≡ 23

test "Draw increases waste by 1" := do
  let state := GameState.new 42
  let state2 := state.draw
  state2.waste.size ≡ 1

-- Win Condition Tests

test "Initial state is not won" := do
  let state := GameState.new 42
  ensure (!state.checkWin) "Initial state should not be won"

end Solitaire.Tests

def main : IO UInt32 := do
  IO.println "╔════════════════════════════════════════╗"
  IO.println "║        Solitaire Test Suite            ║"
  IO.println "╚════════════════════════════════════════╝"
  IO.println ""

  let result ← runAllSuites

  IO.println ""
  if result == 0 then
    IO.println "✓ All tests passed!"
  else
    IO.println "✗ Some tests failed"

  return result
