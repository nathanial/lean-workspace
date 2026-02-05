# Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Twenty48 terminal game.

---

## Feature Proposals

### [Priority: High] Persistent High Score Storage

**Description:** Save the best score to a file so it persists across game sessions.

**Rationale:** Currently, the `bestScore` is only tracked per session and resets when the game exits. A persistent high score is a core feature users expect from 2048 implementations and adds replay value.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Logic.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/App.lean`

**Estimated Effort:** Small

**Dependencies:** None (simple file I/O)

---

### [Priority: High] Multi-Level Undo Stack

**Description:** Allow undoing multiple moves instead of just the last one.

**Rationale:** The current implementation only stores `previousGrid` and `previousScore` for a single undo. Many 2048 implementations allow multiple undos (sometimes unlimited, sometimes limited). This significantly improves the player experience when exploring strategies.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean` (replace `previousGrid : Option Grid` with a stack)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Logic.lean` (push to stack on move, pop on undo)

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Game Statistics Tracking

**Description:** Track and display game statistics such as:
- Total moves made
- Total games played
- Total merges performed
- Highest tile achieved (all-time)
- Average score
- Play time

**Rationale:** Statistics add depth to the game and give players goals beyond reaching 2048. Many puzzle games include statistics to encourage replay.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean` (add stats fields)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Widgets.lean` (add stats display widget)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Draw.lean` (integrate stats into layout)

**Estimated Effort:** Medium

**Dependencies:** Persistent High Score Storage (to save stats to file)

---

### [Priority: Medium] Configurable Grid Size

**Description:** Allow players to choose grid sizes other than 4x4 (e.g., 3x3, 5x5, 6x6).

**Rationale:** Different grid sizes offer different difficulty levels. A 3x3 grid is significantly harder, while 5x5 or 6x6 grids are easier and allow reaching higher tiles.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Types.lean` (parameterize `gridSize`)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Grid.lean` (use dynamic size)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Widgets.lean` (adjust rendering)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Main.lean` (add CLI arguments)

**Estimated Effort:** Medium

**Dependencies:** Consider using parlance for CLI argument parsing

---

### [Priority: Medium] Command-Line Arguments

**Description:** Add command-line argument support for:
- Grid size selection
- Starting seed (for reproducible games)
- Color theme selection
- Disabling animations
- Help and version info

**Rationale:** CLI arguments allow customization and make the game more flexible for different use cases (e.g., speedrunning with a specific seed).

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Main.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/lakefile.lean` (add parlance dependency)

**Estimated Effort:** Small

**Dependencies:** parlance library

---

### [Priority: Medium] Color Theme Support

**Description:** Add multiple color themes (e.g., classic, dark mode, high contrast, colorblind-friendly).

**Rationale:** The current color scheme matches the original 2048 aesthetic, but users may prefer different themes for accessibility or preference. High contrast and colorblind-friendly options would improve accessibility.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Widgets.lean` (extract color definitions into theme structures)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean` (store current theme)

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Sound Effects

**Description:** Add optional sound effects for moves, merges, and game events.

**Rationale:** Audio feedback enhances the game experience. Could leverage the fugue library for cross-platform audio.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/lakefile.lean` (add fugue dependency)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/App.lean` (trigger sounds on events)

**Estimated Effort:** Medium

**Dependencies:** fugue library

---

### [Priority: Low] Daily Challenge Mode

**Description:** A mode where all players share the same daily seed, allowing score comparisons.

**Rationale:** Adds a competitive social element to the game and gives players a reason to return daily.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Logic.lean` (daily seed calculation)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Widgets.lean` (challenge mode display)

**Estimated Effort:** Small

**Dependencies:** chronos library (for date-based seed)

---

### [Priority: Low] AI Solver / Hint System

**Description:** Implement an AI that can suggest optimal moves or auto-play the game.

**Rationale:** Educational value for players wanting to learn better strategies. Also useful for testing and demonstrating the game.

**Affected Files:**
- New file: `Twenty48/Game/AI.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Update.lean` (add hint key)

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: Low] Replay System

**Description:** Record and replay games, allowing players to watch their best games or share replays.

**Rationale:** Adds replay value and allows players to analyze their strategies. Replays could be shared as files.

**Affected Files:**
- New file: `Twenty48/Game/Replay.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean` (add move history)

**Estimated Effort:** Medium

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Extract Magic Numbers to Named Constants

**Current State:** Several magic numbers are scattered throughout the codebase:
- Animation timers (4, 5, 6 frames) in `Logic.lean`
- Tile dimensions (6 width, 3 height) in `Widgets.lean`
- Color indices throughout `Widgets.lean`

**Proposed Change:** Define named constants in a central configuration module:
```lean
def slideAnimFrames : Nat := 4
def mergeAnimFrames : Nat := 6
def spawnAnimFrames : Nat := 5
```

**Benefits:** Easier to tune animation timing, improved code readability, single source of truth.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Logic.lean` (lines 83, 150, 156, 166, 172)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Widgets.lean` (lines 39-42, 59-61, 66-68, 128, 187)

**Estimated Effort:** Small

---

### [Priority: High] Improve Type Safety with Newtypes

**Current State:** Several types are simple aliases that don't prevent misuse:
- `abbrev Tile := Option Nat` - exponent can be confused with actual value
- `Point` x/y can be confused with screen coordinates
- Animation timer is just `Nat`

**Proposed Change:** Use dedicated newtypes or structure wrappers:
```lean
structure Exponent where
  value : Nat
  deriving Repr, BEq

structure GridPos where
  x : Fin gridSize
  y : Fin gridSize
  deriving Repr, BEq
```

**Benefits:** Compile-time prevention of mixing exponents with values, grid positions with screen positions.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Types.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Grid.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Use Fin Types for Grid Bounds

**Current State:** Grid access uses `Nat` indices with runtime bounds checking:
```lean
def Grid.get (g : Grid) (x y : Nat) : Tile :=
  if h1 : y < g.cells.size then ...
```

**Proposed Change:** Use `Fin gridSize` for compile-time bounds checking where possible:
```lean
def Grid.get (g : Grid) (x : Fin gridSize) (y : Fin gridSize) : Tile :=
  g.cells[y][x]
```

**Benefits:** Eliminates runtime bounds checks in hot paths, type-level guarantee of valid indices.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Grid.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Slide.lean`

**Estimated Effort:** Medium

---

### [Priority: Medium] Reduce Code Duplication in Slide Functions

**Current State:** `Grid.slide` and `Grid.slideWithMovement` in `Slide.lean` contain nearly identical logic for each direction, with the only difference being movement tracking.

**Proposed Change:** Refactor to share common logic:
1. Create a generic slide function that accepts a movement tracking flag
2. Or extract the directional transformation logic into reusable helpers

**Benefits:** Reduced code duplication (~100 lines), easier maintenance, single source of truth for slide logic.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Slide.lean` (lines 77-136 vs 212-316)

**Estimated Effort:** Medium

---

### [Priority: Medium] Replace Manual Array Reversal

**Current State:** Custom `reverseArray` function that converts to List and back:
```lean
def reverseArray (arr : Array α) : Array α :=
  arr.toList.reverse.toArray
```

**Proposed Change:** Use the standard library `Array.reverse` (available in Lean 4.x).

**Benefits:** Use idiomatic Lean, potential performance improvement.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Slide.lean` (line 24-25)

**Estimated Effort:** Small

---

### [Priority: Medium] Extract Animation Logic to Dedicated Module

**Current State:** Animation state and update logic is split between `State.lean` and `Logic.lean`.

**Proposed Change:** Create a dedicated `Animation.lean` module containing:
- `AnimPhase` and `AnimState` types
- `updateAnimations` function
- Animation timing constants
- Helper functions for animation state transitions

**Benefits:** Better separation of concerns, easier to extend animation system.

**Affected Files:**
- New file: `Twenty48/Game/Animation.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean`
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Logic.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Optimize Empty Cell Collection

**Current State:** `Grid.emptyCells` builds a reversed list, then reverses it:
```lean
def Grid.emptyCells (g : Grid) : List Point := Id.run do
  let mut result : List Point := []
  for y in ... do
    for x in ... do
      if g.get x y == none then
        result := ⟨x, y⟩ :: result
  result.reverse
```

**Proposed Change:** Build an Array directly without reversal, or use `List.foldr` pattern.

**Benefits:** Minor performance improvement, cleaner code.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Grid.lean` (lines 63-69)

**Estimated Effort:** Small

---

### [Priority: Low] Improve RNG Quality

**Current State:** Uses a simple LCG (Linear Congruential Generator):
```lean
def nextRandom (seed : UInt64) : UInt64 :=
  seed * 6364136223846793005 + 1442695040888963407
```

**Proposed Change:** Consider using a higher-quality RNG like xorshift or PCG for better statistical properties.

**Benefits:** Better randomness distribution, though likely not noticeable in gameplay.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Random.lean`

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: High] Add Documentation Comments to Public API

**Issue:** Most functions lack documentation comments. Only file-level comments exist.

**Location:** All `.lean` files in `Twenty48/Core/`, `Twenty48/Game/`, `Twenty48/UI/`

**Action Required:**
1. Add `/-- ... -/` doc comments to all public functions
2. Document parameters and return values for complex functions
3. Add module-level documentation explaining purpose

**Estimated Effort:** Medium

---

### [Priority: Medium] Add More Comprehensive Tests

**Issue:** Test coverage could be improved. Missing tests for:
- Animation state transitions
- Edge cases in sliding (all empty, all full)
- UI rendering (at least widget dimensions)
- Random number distribution
- Multiple undos (once implemented)

**Location:** `/Users/Shared/Projects/lean-workspace/apps/twenty48/Tests/Main.lean`

**Action Required:**
1. Add tests for animation phase transitions
2. Add property-based tests for slide invariants
3. Add tests for edge cases in grid operations

**Estimated Effort:** Medium

---

### [Priority: Medium] Standardize Error Handling

**Issue:** Some functions silently handle invalid inputs (e.g., `Grid.get` returns `none` for out-of-bounds), while others assume valid input.

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Grid.lean` (lines 24-28, 31-37)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Types.lean` (line 38, `valueToExponent` returns 0 for unexpected values)

**Action Required:**
1. Decide on consistent error handling strategy
2. Document which functions are partial vs total
3. Consider using `Except` or `Option` consistently

**Estimated Effort:** Small

---

### [Priority: Medium] Remove Unused Imports

**Issue:** Some files import more than they use.

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Types.lean` imports `Terminus` but doesn't appear to use it directly
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean` imports `Terminus` but only uses types from Core

**Action Required:** Review imports and remove unnecessary ones.

**Estimated Effort:** Small

---

### [Priority: Low] Consistent Naming Convention

**Issue:** Minor inconsistencies in naming:
- `slideLine` vs `slideLineWithMovement` (verb vs verb+With+Noun)
- `checkGameOver` (verb) vs `hasWinningTile` (verb question)
- Some functions use `new` prefix (`GameState.new`), others use `init` (`initGame`)

**Location:** Various files

**Action Required:** Establish and document naming conventions, refactor for consistency.

**Estimated Effort:** Small

---

### [Priority: Low] Consider Using Lenses for State Updates

**Issue:** State updates are verbose with nested record syntax:
```lean
{ state with
  anim := { state.anim with phase := .merging, timer := 6 }
}
```

**Location:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/Logic.lean` (multiple locations)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Update.lean`

**Action Required:** Consider using the collimator optics library for cleaner nested updates.

**Estimated Effort:** Medium (requires adding dependency and learning optics API)

---

### [Priority: Low] Improve Slide Animation Smoothness

**Issue:** Current interpolation logic in `interpolatePosition` has edge cases:
```lean
let dx := if toScreenX >= fromScreenX
          then (toScreenX - fromScreenX) * progress / total
          else 0  -- Handle negative case separately
```

**Location:** `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/UI/Widgets.lean` (lines 127-153)

**Action Required:** Refactor to use signed arithmetic or a cleaner interpolation approach. Consider using `Float` for smoother animation.

**Estimated Effort:** Small

---

## API Enhancements

### [Priority: Medium] Add GameState Query API

**Description:** Add helper functions for querying game state:
```lean
def GameState.isAnimating : Bool
def GameState.canUndo : Bool
def GameState.moveCount : Nat
def GameState.largestTileValue : Nat
```

**Rationale:** Currently, checking animation state requires accessing nested fields. A cleaner API would make the code more readable.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Add Grid Iterator API

**Description:** Implement standard iteration patterns for Grid:
```lean
instance : ForIn m Grid (Nat × Nat × Tile)
def Grid.tiles : List (Nat × Nat × Tile)
def Grid.mapTiles (f : Tile -> Tile) : Grid
```

**Rationale:** Many operations iterate over all grid cells. A standard iterator would reduce boilerplate.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Grid.lean`

**Estimated Effort:** Small

---

### [Priority: Low] Separate Core Logic from UI Dependencies

**Description:** The `Core` and `Game` modules currently import `Terminus` even though they don't need terminal-specific types.

**Rationale:** Separating pure game logic from UI dependencies would make the core logic reusable (e.g., for a GUI version or web version).

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Core/Types.lean` (remove Terminus import)
- `/Users/Shared/Projects/lean-workspace/apps/twenty48/Twenty48/Game/State.lean` (remove Terminus import)

**Estimated Effort:** Small

---

## Summary

| Priority | Features | Improvements | Cleanup |
|----------|----------|--------------|---------|
| High     | 2        | 2            | 1       |
| Medium   | 4        | 4            | 4       |
| Low      | 4        | 2            | 4       |

### Recommended First Steps

1. **Extract magic numbers to constants** - Quick win with immediate readability benefits
2. **Add persistent high score** - High user value, simple implementation
3. **Add multi-level undo** - High user value, straightforward extension of existing code
4. **Add documentation comments** - Important for maintainability
5. **Remove unused Terminus imports** - Simple cleanup that improves module independence
