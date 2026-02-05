/-
  Twenty48.Game.Random
  Random number generation for tile spawning
-/
import Twenty48.Core

namespace Twenty48.Game

open Twenty48.Core

/-- Linear congruential generator for random numbers -/
def nextRandom (seed : UInt64) : UInt64 :=
  seed * 6364136223846793005 + 1442695040888963407

/-- Get a random value in range [0, max) -/
def randomInRange (seed : UInt64) (max : Nat) : UInt64 × Nat :=
  let next := nextRandom seed
  let value := (next % max.toUInt64).toNat
  (next, value)

/-- Generate a random tile value (90% chance of 2, 10% chance of 4) -/
def randomTileValue (seed : UInt64) : UInt64 × Nat :=
  let (next, roll) := randomInRange seed 10
  let exponent := if roll == 0 then 2 else 1  -- 10% chance of 4 (exp 2), 90% chance of 2 (exp 1)
  (next, exponent)

/-- Pick a random empty cell from the grid -/
def randomEmptyCell (grid : Grid) (seed : UInt64) : UInt64 × Option Point :=
  let emptyCells := grid.emptyCells
  if emptyCells.isEmpty then
    (seed, none)
  else
    let (next, idx) := randomInRange seed emptyCells.length
    match emptyCells[idx]? with
    | some p => (next, some p)
    | none => (next, none)

end Twenty48.Game
