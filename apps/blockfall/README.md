# Blockfall

A Tetris-like falling block puzzle game for the terminal, built in Lean 4 using the [terminus](../terminus) terminal UI library.

## Features

- Classic Tetris gameplay with all 7 tetromino pieces (I, O, T, S, Z, J, L)
- Ghost piece showing where the current piece will land
- Wall kicks for smooth rotation near walls
- Unicode block rendering with colored pieces
- Score, level, and line tracking
- 7-bag randomizer for fair piece distribution

## Building

```bash
lake build
```

## Running

```bash
.lake/build/bin/blockfall
```

## Controls

| Key | Action |
|-----|--------|
| ← / A | Move left |
| → / D | Move right |
| ↓ / S | Soft drop (1 point per cell) |
| ↑ / W | Rotate clockwise |
| Space | Hard drop (2 points per cell) |
| P | Pause / Resume |
| R | Restart |
| Q | Quit |

## Scoring

| Lines Cleared | Points |
|---------------|--------|
| 1 (Single) | 100 × level |
| 2 (Double) | 300 × level |
| 3 (Triple) | 500 × level |
| 4 (Tetris) | 800 × level |

Level increases every 10 lines cleared.

## Testing

```bash
lake test
```

## Project Structure

```
blockfall/
├── Blockfall/
│   ├── Core/
│   │   ├── Types.lean      # Point, Direction, PieceType
│   │   ├── Piece.lean      # Tetromino shapes and rotations
│   │   ├── Board.lean      # Game board grid
│   │   ├── Collision.lean  # Collision detection
│   │   └── WallKick.lean   # SRS wall kick tables
│   ├── Game/
│   │   ├── State.lean      # GameState structure
│   │   ├── Logic.lean      # Movement, rotation, line clearing
│   │   ├── Scoring.lean    # Score calculation
│   │   └── Random.lean     # 7-bag piece randomizer
│   └── UI/
│       ├── App.lean        # Main game loop
│       ├── Draw.lean       # Rendering
│       ├── Update.lean     # Input handling
│       └── Widgets.lean    # Board and UI widgets
├── Tests/
│   └── Main.lean           # Test suite
├── Main.lean               # Entry point
└── lakefile.lean           # Build configuration
```

## Dependencies

- [terminus](../terminus) - Terminal UI library
- [crucible](../crucible) - Test framework

## License

MIT License - see [LICENSE](LICENSE) for details.
