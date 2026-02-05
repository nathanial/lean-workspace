/-
  Blockfall.Game.Scoring
  Score calculation
-/
namespace Blockfall.Game

/-- Points for clearing lines based on count -/
def linePoints (linesCleared level : Nat) : Nat :=
  let base := match linesCleared with
    | 1 => 100   -- Single
    | 2 => 300   -- Double
    | 3 => 500   -- Triple
    | 4 => 800   -- Tetris
    | _ => 0
  base * level

/-- Points for soft drop (per cell) -/
def softDropPoints : Nat := 1

/-- Points for hard drop (per cell) -/
def hardDropPoints : Nat := 2

/-- Lines needed to advance to next level -/
def linesPerLevel : Nat := 10

/-- Calculate level from total lines cleared -/
def levelFromLines (lines : Nat) : Nat :=
  lines / linesPerLevel + 1

/-- Gravity delay in frames (decreases with level) -/
def gravityDelay (level : Nat) : Nat :=
  -- Start at 48 frames, decrease by 5 per level, minimum 1
  let base := 48
  let decrease := (level - 1) * 5
  if decrease >= base then 1 else base - decrease

end Blockfall.Game
