/-
  Minefield.Core.Random
  Random number generation for mine placement
-/

namespace Minefield.Core

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
  if n == 0 then (0, rng)
  else
    let (val, newRng) := rng.next
    (val.toNat % n, newRng)

/-- Fisher-Yates shuffle for any array -/
def shuffleArray [Inhabited α] (rng : RNG) (arr : Array α) : Array α × RNG := Id.run do
  if arr.size <= 1 then return (arr, rng)
  let mut result := arr
  let mut r := rng
  for i in List.range (arr.size - 1) do
    let remaining := arr.size - i
    let (j, newR) := r.nextBounded remaining
    r := newR
    let idx := i + j
    if i < result.size && idx < result.size then
      let tmp := result[i]!
      result := result.setIfInBounds i result[idx]!
      result := result.setIfInBounds idx tmp
  (result, r)

/-- Shuffle a list -/
def shuffleList [Inhabited α] (rng : RNG) (xs : List α) : List α × RNG :=
  let (arr, newRng) := shuffleArray rng xs.toArray
  (arr.toList, newRng)

/-- Pick n random elements from a list (without replacement) -/
def pickN [Inhabited α] (rng : RNG) (xs : List α) (n : Nat) : List α × RNG :=
  let (shuffled, newRng) := shuffleList rng xs
  (shuffled.take n, newRng)

end Minefield.Core
