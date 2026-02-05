# Lighthouse

A terminal UI debugger/inspector for [Ledger](../ledger) databases, built with [Terminus](../terminus).

## Features

- **Entity Browser** - Browse all entities, view attributes, follow entity references with navigation history
- **Transaction Log** - View transaction history with expandable datom details and time-travel queries
- **Attribute Index** - Browse by attribute, see all entities and values for each attribute
- **Query Interface** - Simple pattern queries to find entities

## Installation

```bash
cd lighthouse
lake build
```

## Usage

```bash
.lake/build/bin/lighthouse <database.jsonl>
```

Example:
```bash
.lake/build/bin/lighthouse ../homebase-app/data/homebase.jsonl
```

## Key Bindings

### Global

| Key | Action |
|-----|--------|
| `q` | Quit |
| `1` | Switch to Entity Browser |
| `2` | Switch to Transaction Log |
| `3` | Switch to Attribute Index |
| `4` | Switch to Query Interface |
| `Tab` | Cycle through views |
| `Shift+Tab` | Cycle views backwards |

### Navigation

| Key | Action |
|-----|--------|
| `j` / `Down` | Move selection down |
| `k` / `Up` | Move selection up |
| `h` / `Left` | Focus left pane |
| `l` / `Right` | Focus right pane |
| `Enter` | Select / expand / follow reference |
| `Escape` | Return to left pane |

### View-Specific

| Key | View | Action |
|-----|------|--------|
| `b` | Entity | Go back in navigation history |
| `Space` | Transaction | Toggle expand transaction |
| `t` | Transaction | Toggle time-travel mode |
| `/` | Query | Start typing a query |

## Views

### Entity Browser

Split-pane view with entity list on the left and attribute details on the right. Select an entity to see all its attributes and values. Entity references (shown as `-> Entity N`) can be followed with Enter, and you can navigate back with `b`.

### Transaction Log

Chronological list of all transactions. Each transaction shows:
- Transaction ID
- Number of datoms
- Expandable details showing each datom with `+` (assertion) or `-` (retraction)

Press `t` to enable time-travel mode, which shows the database state as it existed at the selected transaction.

### Attribute Index

Browse all unique attributes in the database. The left pane shows attributes with entity counts. Select an attribute to see all entities that have that attribute and their values. Press Enter on an entity to jump to it in the Entity Browser.

### Query Interface

Simple query interface supporting two patterns:

- `:attribute` - Find all entities with this attribute
- `:attribute="value"` - Find entities where attribute equals value

Examples:
```
:user/name
:card/title="My Task"
:column/order
```

Press `/` to start typing, `Enter` to execute, `Escape` to cancel.

## Dependencies

- [Terminus](../terminus) - Terminal UI library
- [Ledger](../ledger) - Fact-based database
- [Crucible](../crucible) - Test framework

## License

MIT License - see [LICENSE](LICENSE)
