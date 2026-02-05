/-
  Solitaire.Core.Types
  Core type definitions for Klondike Solitaire
-/

namespace Solitaire.Core

/-- The four card suits -/
inductive Suit where
  | spades
  | hearts
  | diamonds
  | clubs
  deriving Repr, BEq, Inhabited, DecidableEq

/-- Check if a suit is red (hearts, diamonds) -/
def Suit.isRed : Suit → Bool
  | .hearts | .diamonds => true
  | _ => false

/-- Check if a suit is black (spades, clubs) -/
def Suit.isBlack (s : Suit) : Bool := !s.isRed

/-- Unicode symbol for a suit -/
def Suit.symbol : Suit → String
  | .spades => "♠"
  | .hearts => "♥"
  | .diamonds => "♦"
  | .clubs => "♣"

/-- All suits in order -/
def Suit.all : List Suit := [.spades, .hearts, .diamonds, .clubs]

/-- Card ranks (Ace=1 through King=13) -/
inductive Rank where
  | ace
  | two
  | three
  | four
  | five
  | six
  | seven
  | eight
  | nine
  | ten
  | jack
  | queen
  | king
  deriving Repr, BEq, Inhabited, DecidableEq

/-- Numeric value of a rank (1-13) -/
def Rank.value : Rank → Nat
  | .ace => 1
  | .two => 2
  | .three => 3
  | .four => 4
  | .five => 5
  | .six => 6
  | .seven => 7
  | .eight => 8
  | .nine => 9
  | .ten => 10
  | .jack => 11
  | .queen => 12
  | .king => 13

/-- Display string for a rank -/
def Rank.display : Rank → String
  | .ace => "A"
  | .two => "2"
  | .three => "3"
  | .four => "4"
  | .five => "5"
  | .six => "6"
  | .seven => "7"
  | .eight => "8"
  | .nine => "9"
  | .ten => "10"
  | .jack => "J"
  | .queen => "Q"
  | .king => "K"

/-- All ranks in order -/
def Rank.all : List Rank :=
  [.ace, .two, .three, .four, .five, .six, .seven,
   .eight, .nine, .ten, .jack, .queen, .king]

/-- A playing card -/
structure Card where
  suit : Suit
  rank : Rank
  deriving Repr, BEq, Inhabited

/-- Display string for a card (e.g., "A♠", "10♥") -/
def Card.display (c : Card) : String :=
  c.rank.display ++ c.suit.symbol

/-- Check if card2 can stack on card1 in tableau (alternating colors, descending) -/
def Card.canStackOnTableau (bottom top : Card) : Bool :=
  bottom.suit.isRed != top.suit.isRed &&
  bottom.rank.value == top.rank.value + 1

/-- Check if card can be placed on foundation (same suit, ascending from Ace) -/
def Card.canStackOnFoundation (foundationTop : Option Card) (card : Card) : Bool :=
  match foundationTop with
  | none => card.rank == .ace
  | some top => card.suit == top.suit && card.rank.value == top.rank.value + 1

/-- A card that may be face-up or face-down (for tableau) -/
structure TableauCard where
  card : Card
  faceUp : Bool
  deriving Repr, BEq, Inhabited

/-- Location identifiers for card piles -/
inductive PileId where
  | stock
  | waste
  | foundation (index : Fin 4)
  | tableau (index : Fin 7)
  deriving Repr, BEq, Inhabited

/-- Cursor position for navigation -/
inductive CursorPos where
  | stock
  | waste
  | foundation (index : Fin 4)
  | tableau (index : Fin 7) (cardIndex : Nat)
  deriving Repr, BEq, Inhabited

/-- A selection (source pile and how many cards) -/
structure Selection where
  pile : PileId
  cardCount : Nat := 1
  deriving Repr, BEq, Inhabited

end Solitaire.Core
