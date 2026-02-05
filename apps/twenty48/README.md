# Twenty48

A terminal-based 2048 game written in Lean 4 using the [terminus](../terminus) library.

## Building

```bash
lake build
```

## Running

```bash
.lake/build/bin/twenty48
```

## Controls

| Key | Action |
|-----|--------|
| Arrow keys | Slide tiles |
| W/A/S/D | Slide tiles (alternative) |
| U | Undo last move |
| R | Restart game |
| C | Continue playing after reaching 2048 |
| Q | Quit |

## Gameplay

- Slide tiles in any of the four directions
- When two tiles with the same number touch, they merge into one with double the value
- After each move, a new tile (2 or 4) appears in a random empty cell
- Reach 2048 to win, or keep going for a higher score
- Game ends when no moves are possible

## Features

- Colored tiles matching the original 2048 aesthetic
- Undo functionality (one move back)
- Best score tracking (per session)
- Merge and new tile animations
- Win screen with option to continue
- Game over detection

## Testing

```bash
lake test
```

## Project Structure

```
twenty48/
├── Twenty48/
│   ├── Core/
│   │   ├── Types.lean    # Direction, Point, Tile types
│   │   ├── Grid.lean     # 4x4 grid operations
│   │   └── Slide.lean    # Slide and merge logic
│   ├── Game/
│   │   ├── State.lean    # GameState and AnimState
│   │   ├── Logic.lean    # Move processing, win/lose
│   │   └── Random.lean   # Tile spawning RNG
│   ├── UI/
│   │   ├── Widgets.lean  # Tile and grid rendering
│   │   ├── Draw.lean     # Frame composition
│   │   ├── Update.lean   # Input handling
│   │   └── App.lean      # Main game loop
│   ├── Core.lean
│   ├── Game.lean
│   └── UI.lean
├── Tests/
│   └── Main.lean
├── Main.lean
├── Twenty48.lean
└── lakefile.lean
```

## Dependencies

- [terminus](../terminus) - Terminal UI library
- [crucible](../crucible) - Test framework

## License

MIT License - see [LICENSE](LICENSE)
