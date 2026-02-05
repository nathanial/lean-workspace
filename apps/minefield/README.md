# Minefield

A terminal-based Minesweeper game written in Lean 4 using the [terminus](https://github.com/nathanial/terminus) terminal UI library.

## Features

- Classic Minesweeper gameplay with keyboard controls
- Three difficulty levels: Beginner, Intermediate, Expert
- Safe first click (first reveal always opens an area)
- Chord feature (reveal neighbors when flags match number)
- Timer display
- Cursor-based navigation with edge wrapping

## Controls

| Key | Action |
|-----|--------|
| Arrow keys / WASD | Move cursor |
| Space / Enter | Reveal cell |
| F | Toggle flag |
| C | Chord (reveal unflagged neighbors if flag count matches) |
| R | Restart game |
| 1 | Beginner (9x9, 10 mines) |
| 2 | Intermediate (16x16, 40 mines) |
| 3 | Expert (30x16, 99 mines) |
| Q | Quit |

## Building

Requires Lean 4.26.0 and Lake.

```bash
lake build minefield
```

## Running

```bash
.lake/build/bin/minefield
```

## Testing

```bash
lake test
```

## Screenshot

```
MINEFIELD                           Beginner

Mines: 10  Time: 00:15  [PLAYING]

┌──────────────────┐
│ . . . 1 ■ ■ ■ ■ ■│
│ . . . 1 2 ■ ■ ■ ■│
│ . . . . 1[■]■ ■ ■│
│ . 1 1 1 1 ■ ■ ■ ■│
│ . 1 ■ ■ ■ ■ ■ ■ ■│
│ . 1 2 ■ ■ ■ ■ ■ ■│
│ . . 1 ■ ■ ■ ■ ■ ■│
│ . . 1 1 1 ■ ■ ■ ■│
│ . . . . 1 ■ ■ ■ ■│
└──────────────────┘

┌─────────────────┐
│    CONTROLS     │
├─────────────────┤
│ ↑↓←→/WASD  Move │
│ Space    Reveal │
│ F          Flag │
│ C         Chord │
│ R       Restart │
│ 1/2/3     Diff. │
│ Q          Quit │
└─────────────────┘
```

## Project Structure

```
minefield/
├── Main.lean                 # Entry point
├── Minefield.lean            # Top-level exports
├── Minefield/
│   ├── Core/
│   │   ├── Types.lean        # Cell, CellState, Difficulty, Point
│   │   ├── Grid.lean         # Grid structure and operations
│   │   ├── Random.lean       # RNG for mine placement
│   │   └── Generate.lean     # Mine placement with safe first click
│   ├── Game/
│   │   ├── State.lean        # GameState, GameStatus
│   │   └── Logic.lean        # reveal, flag, chord, win/lose
│   └── UI/
│       ├── App.lean          # Main application loop
│       ├── Draw.lean         # Frame rendering
│       ├── Update.lean       # Input handling
│       └── Widgets.lean      # Cell rendering, overlays
└── Tests/
    └── Main.lean             # Test suite (28 tests)
```

## Dependencies

- [terminus](https://github.com/nathanial/terminus) - Terminal UI library
- [crucible](https://github.com/nathanial/crucible) - Test framework

## License

MIT License - see [LICENSE](LICENSE) file.
