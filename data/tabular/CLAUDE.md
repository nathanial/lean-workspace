# CLAUDE.md

CSV/TSV parser library for Lean 4 with typed column extraction.

## Build Commands

```bash
lake build        # Build the library
lake test         # Run tests
```

## Project Structure

```
Tabular.lean              # Main entry point and API
Tabular/
  Core/
    Config.lean           # Parser configuration (delimiter, headers, etc.)
    Value.lean            # Cell value representation
    Row.lean              # Row type with indexed/named access
    Table.lean            # Table with headers and rows
    Error.lean            # ParseError and ExtractError types
  Parser/
    Field.lean            # Field-level parsing (quoted/unquoted)
    Record.lean           # Row/record parsing
    Document.lean         # Full document parsing
  Extract.lean            # FromCsv typeclass for typed extraction
Tests/
  Main.lean               # Test entry point
  ParserTests.lean        # Parser unit tests
  ExtractTests.lean       # Type extraction tests
```

## Dependencies

- `sift` - Parser combinator library
- `crucible` - Test framework

## Key Types

- `Config` - Parser configuration (delimiter, hasHeader, trimWhitespace, allowRagged)
- `Table` - Parsed table with optional headers and rows
- `Row` - Single row with column access by index or name
- `Value` - Cell value (string content)
- `ParseResult α` - `Except ParseError α`
- `ExtractResult α` - `Except ExtractError α`
- `FromCsv α` - Typeclass for typed extraction (String, Int, Nat, Float, Bool, Option)

## API Patterns

```lean
-- Parse with config
Tabular.parse csv Config.csv
Tabular.parse tsv Config.tsv

-- Access by name (case-insensitive)
row.getByNameAs (α := Int) "age"

-- Access by index
row.getAs (α := String) 0

-- Convert results to IO
Tabular.toIO result
```

## Predefined Configs

- `Config.csv` - Comma-separated (default)
- `Config.tsv` - Tab-separated
- `Config.psv` - Pipe-separated
- `Config.scsv` - Semicolon-separated (European CSV)
