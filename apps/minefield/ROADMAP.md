# Minefield Roadmap

A terminal Minesweeper game built with the terminus terminal UI library for Lean 4.

---

## Feature Proposals

### [Priority: High] High Scores and Statistics Tracking

**Description:** Implement persistent high scores and gameplay statistics.

**Rationale:** This is a core feature expected in any Minesweeper implementation. Tracking best times per difficulty motivates replay and provides a sense of progression.

**Proposed Features:**
- Save best completion times per difficulty level
- Track win/loss statistics (games played, win rate)
- Display statistics on a dedicated screen (accessible via 'S' key)
- Store data in a JSON file in the user's config directory

**Affected Files:**
- New file: `Minefield/Stats/Persistence.lean` - File I/O for stats
- New file: `Minefield/Stats/Types.lean` - Stats data structures
- `Minefield/Game/State.lean` - Add end-game stats recording
- `Minefield/UI/Widgets.lean` - Stats display widget
- `Minefield/UI/Update.lean` - Handle stats screen toggle

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: High] Mouse Support

**Description:** Add mouse input handling for cell selection, reveals, and flags.

**Rationale:** Traditional Minesweeper is primarily a mouse-driven game. Mouse support would make the game more accessible and familiar to players.

**Proposed Features:**
- Left-click to reveal cells
- Right-click to flag/unflag cells
- Middle-click (or left+right) for chord action
- Mouse hover for cursor positioning

**Affected Files:**
- `Minefield/UI/Update.lean` - Handle `Event.mouse` events
- `Minefield/UI/Draw.lean` - Calculate screen-to-grid coordinate mapping
- May require terminus library updates for mouse event support

**Estimated Effort:** Medium

**Dependencies:** Verify terminus supports mouse events

---

### [Priority: Medium] Custom Difficulty Configuration

**Description:** Allow players to create custom game configurations beyond the three presets.

**Rationale:** Power users often want to practice with specific grid sizes or mine densities.

**Proposed Features:**
- Configuration screen for width, height, and mine count
- Validate mine count is feasible (less than total cells minus safe zone)
- Save last custom configuration
- Access via 'X' key or number '4'

**Affected Files:**
- `Minefield/Core/Types.lean` - Add custom difficulty validation
- `Minefield/UI/Update.lean` - Handle custom difficulty input
- `Minefield/UI/Widgets.lean` - Custom difficulty input form
- New file: `Minefield/UI/CustomDifficulty.lean` - Configuration screen

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Question Mark State

**Description:** Add a third cell marking state (question mark) as in classic Minesweeper.

**Rationale:** Many players use question marks to indicate "maybe a mine" cells during complex deductions.

**Proposed Features:**
- Cycle through: hidden -> flagged -> question mark -> hidden
- Question mark cells can be revealed (unlike flagged cells)
- Display '?' character with distinct styling

**Affected Files:**
- `Minefield/Core/Types.lean` - Add `CellState.questionMarked` variant
- `Minefield/Game/Logic.lean` - Update `toggleFlag` to cycle through states
- `Minefield/UI/Widgets.lean` - Render question mark cells
- `Tests/Main.lean` - Add tests for question mark behavior

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Undo/Redo for Flags

**Description:** Allow undoing and redoing flag placements.

**Rationale:** Players sometimes misclick when flagging; undo support improves the experience without affecting the core game challenge.

**Proposed Features:**
- Track flag actions in a history stack
- Undo with 'U' key, redo with Ctrl+R
- Clear history on reveal actions (to prevent cheating)
- Display undo availability in UI

**Affected Files:**
- `Minefield/Game/State.lean` - Add flag action history
- `Minefield/Game/Logic.lean` - Push actions to history, implement undo/redo
- `Minefield/UI/Update.lean` - Handle undo/redo keys
- `Minefield/UI/Widgets.lean` - Show undo availability

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Low] Sound Effects

**Description:** Add audio feedback for game events.

**Rationale:** Audio enhances game feel and provides immediate feedback.

**Proposed Features:**
- Click sound on reveal
- Flag placement sound
- Explosion sound on mine hit
- Victory fanfare
- Optional mute toggle (M key)

**Affected Files:**
- New dependency: `fugue` library for audio
- `lakefile.lean` - Add fugue dependency
- New file: `Minefield/Audio.lean` - Sound effect definitions
- `Minefield/Game/Logic.lean` - Trigger sounds on actions
- `Minefield/UI/Update.lean` - Mute toggle

**Estimated Effort:** Medium

**Dependencies:** fugue library

---

### [Priority: Low] Seed Display and Replay

**Description:** Display the current game seed and allow replaying specific seeds.

**Rationale:** Allows sharing specific puzzles with others or practicing difficult boards.

**Proposed Features:**
- Display current seed on game over/win screen
- Allow entering a seed via command line argument
- Copy seed to clipboard (if terminal supports)

**Affected Files:**
- `Main.lean` - Parse seed from command line
- `Minefield/Game/State.lean` - Store and expose seed
- `Minefield/UI/Widgets.lean` - Display seed in overlays

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Hint System

**Description:** Provide optional hints for players who are stuck.

**Rationale:** Educational feature for players learning Minesweeper strategy.

**Proposed Features:**
- 'H' key reveals a safe cell or obvious mine
- Track hint usage in statistics
- Hints disable high score eligibility for that game

**Affected Files:**
- `Minefield/Game/State.lean` - Track hint usage
- `Minefield/Game/Logic.lean` - Implement hint finding algorithm
- `Minefield/UI/Update.lean` - Handle hint key

**Estimated Effort:** Medium

**Dependencies:** None

---

## Code Improvements

### [Priority: High] Improve RNG Quality

**Current State:** The `RNG` in `Minefield/Core/Random.lean` uses a simple LCG (Linear Congruential Generator) with parameters that produce only 2^31 distinct values.

**Proposed Change:** Replace with a higher-quality PRNG such as xorshift128+ or PCG, which provide better statistical properties and longer periods.

**Benefits:**
- Better randomness distribution for mine placement
- Avoid potential patterns in generated boards
- More robust for larger grids

**Affected Files:**
- `Minefield/Core/Random.lean` - Replace LCG implementation

**Estimated Effort:** Small

---

### [Priority: Medium] Extract Coordinate Mapping to Shared Module

**Current State:** Grid-to-screen and screen-to-grid coordinate calculations are inline in `Draw.lean`.

**Proposed Change:** Create a `Minefield/UI/Layout.lean` module with reusable coordinate transformation functions.

**Benefits:**
- Enables mouse support (screen coords to grid coords)
- Reduces duplication between rendering and input handling
- Cleaner separation of concerns

**Affected Files:**
- New file: `Minefield/UI/Layout.lean`
- `Minefield/UI/Draw.lean` - Use layout module
- `Minefield/UI/Update.lean` - Use layout module for future mouse support

**Estimated Effort:** Small

---

### [Priority: Medium] Use Terminus Widgets for UI Components

**Current State:** Custom rendering functions (`renderControls`, `renderWinOverlay`, etc.) manually draw borders and text.

**Proposed Change:** Leverage terminus's built-in widgets (Block, Paragraph, Table) for consistent styling and reduced code.

**Benefits:**
- Consistent visual style with other terminus apps
- Less manual coordinate calculation
- Easier to maintain and modify layouts

**Affected Files:**
- `Minefield/UI/Widgets.lean` - Refactor to use terminus widgets

**Estimated Effort:** Medium

---

### [Priority: Medium] Add Type Safety to Grid Access

**Current State:** `Grid.get` returns a default `Cell` when out of bounds, which could mask bugs.

**Proposed Change:** Add `Grid.get?` returning `Option Cell` and use it in critical paths. Keep the current `get` for convenience but document its default-returning behavior.

**Benefits:**
- Catch out-of-bounds access bugs during development
- More explicit error handling

**Affected Files:**
- `Minefield/Core/Grid.lean` - Add `get?` function
- `Minefield/Game/Logic.lean` - Use `get?` where appropriate
- `Minefield/Core/Generate.lean` - Use `get?` where appropriate

**Estimated Effort:** Small

---

### [Priority: Low] Optimize Flood-Fill Algorithm

**Current State:** `floodReveal` in `Logic.lean` is marked `partial` and uses recursion, which could stack overflow on very large grids.

**Proposed Change:** Convert to an iterative algorithm using an explicit worklist/queue.

**Benefits:**
- Handles arbitrarily large grids without stack overflow
- Removes `partial` annotation
- Potentially better performance

**Affected Files:**
- `Minefield/Game/Logic.lean` - Rewrite `floodReveal`

**Estimated Effort:** Small

---

### [Priority: Low] Consolidate Layout Constants

**Current State:** Layout values like `sidebarWidth := 20`, `gridScreenWidth`, `boxWidth := 22` are scattered across rendering code.

**Proposed Change:** Define layout constants in a central location, possibly in a `Minefield/UI/Theme.lean` or `Layout.lean` module.

**Benefits:**
- Easier to adjust visual appearance
- Single source of truth for dimensions

**Affected Files:**
- New file: `Minefield/UI/Theme.lean` or addition to `Layout.lean`
- `Minefield/UI/Draw.lean` - Reference constants
- `Minefield/UI/Widgets.lean` - Reference constants

**Estimated Effort:** Small

---

## Code Cleanup

### [Priority: High] Add Documentation Comments

**Issue:** Most functions lack doc comments explaining their purpose, parameters, and return values.

**Location:** All files in `Minefield/` directory

**Action Required:**
- Add `/-- ... -/` doc comments to all public functions
- Document type parameters and fields
- Add module-level documentation explaining each file's purpose

**Estimated Effort:** Medium

---

### [Priority: Medium] Improve Test Coverage

**Issue:** While core logic has good coverage, UI-related logic is untested.

**Location:** `Tests/Main.lean`

**Action Required:**
- Add tests for `formatTime` function
- Add tests for coordinate calculations in rendering
- Add tests for `cellAppearance` function
- Test edge cases in cursor movement at grid boundaries
- Add tests for game state transitions (playing -> won, playing -> lost)

**Estimated Effort:** Medium

---

### [Priority: Medium] Remove Unused Parameters

**Issue:** `GameState.changeDifficulty` has an unused `_s` parameter (the current state).

**Location:** `Minefield/Game/State.lean`, line 85

**Action Required:** Either use the parameter (e.g., preserve RNG state) or change to a static function.

**Estimated Effort:** Small

---

### [Priority: Low] Consistent Naming Convention

**Issue:** Mixed use of `Point` vs `x, y` pairs in function signatures.

**Location:**
- `Grid.lean` has both `Grid.get(x, y)` and `Grid.getPoint(p)`
- Similar pattern in `modify`, `set`, etc.

**Action Required:** Decide on primary interface (prefer `Point` for consistency) and deprecate or remove duplicates.

**Estimated Effort:** Small

---

### [Priority: Low] Clean Up Id.run Usage

**Issue:** Several functions use `Id.run do` for imperative-style code where a more functional approach might be cleaner.

**Location:**
- `Minefield/Game/Logic.lean` - `revealCell`, `toggleFlag`, `chord`
- `Minefield/UI/Widgets.lean` - All render functions

**Action Required:** Evaluate if StateM or ReaderT would be more appropriate. In many cases `Id.run do` is fine, but some could be simplified.

**Estimated Effort:** Small

---

### [Priority: Low] Improve Error Messages

**Issue:** No user-visible error handling for edge cases like terminal too small to display the grid.

**Location:** `Minefield/UI/Draw.lean`

**Action Required:**
- Check terminal dimensions before rendering
- Display a friendly message if terminal is too small
- Suggest minimum terminal size in error

**Estimated Effort:** Small

---

## Technical Debt

### [Priority: Medium] Consider Separating Pure Game Logic from IO

**Issue:** Game logic in `Logic.lean` is mostly pure, but `revealCell` takes `currentTime : Nat` which couples it to IO concerns.

**Location:** `Minefield/Game/Logic.lean`

**Action Required:** Consider passing time through a context or making it optional for testing purposes.

**Estimated Effort:** Small

---

### [Priority: Low] Array vs List Performance

**Issue:** Some operations use `List` where `Array` might be more efficient, particularly in grid iteration.

**Location:**
- `Minefield/Core/Grid.lean` - `allPositions` returns `List Point`
- `Minefield/Core/Random.lean` - `shuffleList` converts to/from Array

**Action Required:** Profile if needed; for current grid sizes (max 30x16 = 480 cells) this is unlikely to be a bottleneck.

**Estimated Effort:** Small

---

## Future Considerations

- **Multiplayer Mode:** Real-time competitive Minesweeper using networking
- **Themed Skins:** Different character sets for cells (emoji, ASCII art)
- **Accessibility:** Screen reader support, color-blind friendly palettes
- **Mobile/Touch:** Abstract input handling for potential touch interface
- **AI Solver:** Implement a Minesweeper solver for hint generation and analysis
