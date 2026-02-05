/-
  Blockfall.Game.Random
  Piece randomization using 7-bag system
-/
import Blockfall.Core

namespace Blockfall.Game

open Blockfall.Core

/-- Simple linear congruential generator state -/
structure RNG where
  seed : UInt64
  deriving Repr, Inhabited

/-- Create RNG from a seed -/
def RNG.new (seed : UInt64) : RNG := ⟨seed⟩

/-- Get next random value and updated RNG -/
def RNG.next (rng : RNG) : UInt64 × RNG :=
  -- LCG parameters (same as glibc)
  let a : UInt64 := 1103515245
  let c : UInt64 := 12345
  let m : UInt64 := 0x80000000  -- 2^31
  let newSeed := (a * rng.seed + c) % m
  (newSeed, ⟨newSeed⟩)

/-- Get a random number in range [0, n) -/
def RNG.nextBounded (rng : RNG) (n : Nat) : Nat × RNG :=
  let (val, newRng) := rng.next
  (val.toNat % n, newRng)

/-- Fisher-Yates shuffle -/
def shuffle [Inhabited α] (rng : RNG) (xs : List α) : List α × RNG := Id.run do
  let mut arr := xs.toArray
  let mut r := rng
  for i in List.range (arr.size - 1) do
    let (j, newR) := r.nextBounded (arr.size - i)
    r := newR
    let idx := i + j
    if i < arr.size && idx < arr.size then
      let tmp := arr[i]!
      arr := arr.setIfInBounds i arr[idx]!
      arr := arr.setIfInBounds idx tmp
  (arr.toList, r)

/-- The 7-bag randomizer state -/
structure Bag where
  pieces : List PieceType
  rng : RNG
  deriving Repr, Inhabited

/-- Create a new bag with shuffled pieces -/
def Bag.new (rng : RNG) : Bag :=
  let (shuffled, newRng) := shuffle rng PieceType.all
  { pieces := shuffled, rng := newRng }

/-- Get next piece from bag, refilling if empty -/
def Bag.next (bag : Bag) : PieceType × Bag :=
  match bag.pieces with
  | [] =>
    -- Refill bag
    let newBag := Bag.new bag.rng
    match newBag.pieces with
    | p :: rest => (p, { newBag with pieces := rest })
    | [] => (.T, bag)  -- Shouldn't happen
  | p :: rest =>
    (p, { bag with pieces := rest })

/-- Peek at next piece without consuming -/
def Bag.peek (bag : Bag) : PieceType :=
  match bag.pieces with
  | [] =>
    -- Would refill, return first of new shuffle
    let newBag := Bag.new bag.rng
    newBag.pieces.head?.getD .T
  | p :: _ => p

end Blockfall.Game
