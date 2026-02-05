# Solitaire

Terminal-based Klondike Solitaire written in Lean 4.

## Features

- Classic Klondike Solitaire with Draw-1 mode
- Keyboard-driven interface with cursor navigation
- Undo support
- Win detection

## Requirements

- Lean 4.26.0+
- Terminal with Unicode support

## Building

```bash
lake build
```

## Running

```bash
lake exe solitaire
```

## Controls

| Key | Action |
|-----|--------|
| Arrows / WASD | Move cursor |
| Enter / Space | Select card or place selection |
| Escape | Cancel selection |
| S | Draw from stock / reset stock |
| U | Undo last move |
| R | Restart game |
| Q | Quit |

## Gameplay

1. Navigate to a card using arrow keys
2. Press Enter to select the card (or stack of cards)
3. Navigate to the destination
4. Press Enter to place the selection

### Rules

- **Tableau**: Stack cards in alternating colors, descending rank (K, Q, J, 10, ... A)
- **Foundation**: Build up by suit from Ace to King
- **Empty tableau**: Only Kings can be placed on empty tableau piles
- **Win condition**: All cards moved to the four foundation piles

## Project Structure

```
solitaire/
├── Main.lean              # Entry point
├── Solitaire.lean         # Root module
├── Solitaire/
│   ├── Core/
│   │   ├── Types.lean     # Card, Suit, Rank, etc.
│   │   ├── Deck.lean      # Shuffle and deck creation
│   │   └── Piles.lean     # Pile operations
│   ├── Game/
│   │   ├── State.lean     # Game state
│   │   ├── Init.lean      # Deal cards
│   │   ├── Validation.lean# Move validation
│   │   └── Logic.lean     # Move execution
│   └── UI/
│       ├── App.lean       # Game loop
│       ├── Update.lean    # Input handling
│       ├── Draw.lean      # Rendering
│       └── Widgets.lean   # Card widgets
└── Tests/
    └── Main.lean          # Unit tests
```

## Testing

```bash
lake test
```

## Dependencies

- [terminus](https://github.com/nathanial/terminus) - Terminal UI library
- [crucible](https://github.com/nathanial/crucible) - Test framework

## License

MIT License - see [LICENSE](LICENSE) for details.
