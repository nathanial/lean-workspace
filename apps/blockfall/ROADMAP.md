# Blockfall Roadmap

This document outlines potential enhancements, cleanup tasks, and new features for the blockfall project.

## Current State

Blockfall is a functional Tetris clone with:
- All 7 tetromino pieces with SRS wall kicks
- Ghost piece preview
- 7-bag randomizer
- Line clearing with animations
- Hard drop with trail effect
- Lock flash animation
- Game over fill animation
- Score, level, and line tracking
- Pause/restart functionality

## Gameplay Enhancements

### High Priority

#### Hold Piece
Allow players to hold the current piece and swap it later.
- Add `held : Option PieceType` to `GameState`
- Add 'C' or 'Shift' key binding
- Render hold box in sidebar
- Prevent hold spam (only once per piece)

#### Lock Delay
Add a grace period before pieces lock, allowing last-second moves.
- Add `lockDelayTimer : Nat` to `GameState`
- Reset timer on successful move/rotate
- Lock only when timer expires while grounded
- Standard delay: ~30 frames (0.5s)

#### DAS (Delayed Auto Shift)
Smooth auto-repeat for held movement keys.
- Track key hold duration
- Initial delay before repeat (~10 frames)
- Fast repeat rate after (~2 frames)
- Improves feel for rapid movement

#### Multiple Next Pieces
Show 3-5 upcoming pieces instead of just one.
- Modify `Bag` to support peek ahead
- Update sidebar UI to show piece queue
- Helps planning and strategy

### Medium Priority

#### T-Spin Detection
Detect and reward T-spin moves with bonus points.
- Check 3 of 4 corners filled after T rotation
- T-Spin Mini vs T-Spin detection
- Bonus scoring: T-Spin Single (800), Double (1200), Triple (1600)

#### Combo System
Award bonus points for consecutive line clears.
- Track `comboCount : Nat` in `GameState`
- Reset on piece lock without clear
- Bonus: 50 * combo * level

#### Back-to-Back Bonus
Reward consecutive "difficult" clears (Tetris, T-Spins).
- Track `backToBack : Bool` in `GameState`
- 1.5x multiplier for B2B clears

#### Soft Drop Speed
Make soft drop faster at higher levels.
- Currently: 1 point per cell, normal speed
- Enhancement: Instant soft drop option
- Or: Gravity-relative soft drop speed

### Low Priority

#### ARE (Appearance Delay)
Brief pause after line clear before next piece.
- More traditional Tetris feel
- Could tie into line clear animation timing

#### Initial Rotation System (IRS)
Allow rotation input during piece spawn.
- Buffer rotation during spawn delay
- Piece appears already rotated

#### Initial Hold System (IHS)
Allow hold input during piece spawn.
- Immediately swap with held piece on spawn

## Game Modes

### Sprint Mode
Clear 40 lines as fast as possible.
- Track elapsed time
- End condition: 40 lines cleared
- Display: time, lines remaining

### Ultra Mode
Score as many points as possible in 2 minutes.
- Countdown timer
- End condition: timer reaches 0
- Display: time remaining, score

### Marathon Mode (Current)
Play until game over, increasing difficulty.
- Current default mode
- Could add level cap option (level 15, 20, etc.)

### Endless Mode
Like marathon but gravity caps at a playable speed.
- No game over from speed
- For relaxed play or practice

## Visual Enhancements

### Theme System
Allow different color schemes.
- Classic (current)
- Monochrome
- High contrast
- Custom color definitions

### Improved Animations
- Screen flash on Tetris clear
- Subtle shake on hard drop (if terminal supports cursor positioning)
- Fade effect for ghost piece based on distance

### Statistics Display
Show detailed stats during/after game.
- Pieces placed per type
- Lines cleared by type (single/double/triple/tetris)
- Max combo
- T-spins performed

### Title Screen
Add a title screen before game starts.
- ASCII art logo
- Menu: Start, Options, High Scores, Quit
- Brief controls reminder

## Technical Improvements

### High Score Persistence
Save and load high scores to disk.
- JSON file in config directory
- Top 10 scores with date
- Display on game over

### Configuration File
Allow customization without recompilation.
- Key bindings
- DAS/ARR settings
- Starting level
- Ghost piece toggle

### Improved Random Seed
Currently uses `IO.monoMsNow` for seed.
- Consider more entropy sources
- Allow manual seed input for reproducible games

### Input Handling Improvements
- Distinguish key press vs key release (if terminal supports)
- Handle simultaneous key presses better
- Configurable key repeat settings

## Code Quality

### Additional Tests

#### Integration Tests
- Full game simulation tests
- Replay system for regression testing

#### Edge Case Tests
- Wall kick at all board positions
- Line clear at top of board
- Rapid input sequences

#### Property-Based Tests
When Plausible becomes compatible with Lean 4.26+:
- Random board configurations
- Arbitrary piece sequences
- Fuzz testing for crashes

### Formal Verification
Lean 4's proof capabilities could verify:
- `clearLines` never removes incomplete rows (theorem)
- Board dimensions are invariant (theorem)
- Score is monotonically increasing (theorem)
- Piece spawn position is always valid (theorem)

Example sketch:
```lean
theorem clearLines_only_complete (b : Board) :
  let (b', _) := b.clearLines
  ∀ row ∈ b.completeRows, ∀ y, b'.get · y ≠ b.get · row := by
  sorry -- prove rows are actually removed

theorem clearLines_preserves_incomplete (b : Board) :
  let (b', _) := b.clearLines
  ∀ row, ¬b.isRowComplete row →
    ∃ y, ∀ x, b'.get x y = b.get x row := by
  sorry -- prove incomplete rows are preserved (shifted)
```

### Documentation
- Add docstrings to all public functions
- Architecture overview in README
- Contributing guidelines

### Code Cleanup
- Extract magic numbers to constants (animation durations, etc.)
- Consider separating animation state from game state
- Review and simplify wall kick logic

## Platform Considerations

### Terminal Compatibility
- Test on different terminal emulators
- Handle terminals without 256-color support
- Graceful degradation for missing Unicode support

### Performance
- Profile rendering performance
- Consider dirty-rectangle optimization
- Minimize allocations in hot paths

## Dependencies

### Terminus Enhancements
Features that would benefit from terminus improvements:
- Mouse input for menu navigation
- True color (24-bit) support
- Terminal bell/sound

## Version Milestones

### v0.2 - Quality of Life
- [ ] Hold piece
- [ ] Lock delay
- [ ] Multiple next piece preview
- [ ] High score saving

### v0.3 - Advanced Mechanics
- [ ] T-spin detection
- [ ] Combo system
- [ ] Back-to-back bonus
- [ ] DAS/ARR settings

### v0.4 - Game Modes
- [ ] Sprint mode
- [ ] Ultra mode
- [ ] Mode selection menu

### v0.5 - Polish
- [ ] Title screen
- [ ] Statistics tracking
- [ ] Theme system
- [ ] Configuration file

### v1.0 - Complete
- [ ] All core features stable
- [ ] Comprehensive test suite
- [ ] Full documentation
- [ ] Some formal proofs
