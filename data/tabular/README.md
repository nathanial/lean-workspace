# Tabular

A CSV/TSV parser library for Lean 4 with typed column extraction.

## Features

- **Configurable delimiter** - CSV, TSV, pipe-separated, or any custom character
- **Optional headers** - Parse with or without a header row
- **RFC 4180 compliant** - Quoted fields, escaped quotes, embedded newlines
- **Typed extraction** - `FromCsv` typeclass for String, Int, Nat, Float, Bool, Option
- **Case-insensitive column names** - Column lookups ignore case

## Installation

Add to your `lakefile.lean`:

```lean
require tabular from git "https://github.com/nathanial/tabular" @ "v0.0.1"
```

## Quick Start

```lean
import Tabular

def main : IO Unit := do
  let csv := "name,age,active\nAlice,30,true\nBob,25,false"

  match Tabular.parse csv with
  | .ok table =>
    for row in table.rows do
      let name ← row.getByNameAs (α := String) "name" |> Tabular.toIO
      let age ← row.getByNameAs (α := Int) "age" |> Tabular.toIO
      let active ← row.getByNameAs (α := Bool) "active" |> Tabular.toIO
      IO.println s!"{name} is {age} years old, active: {active}"
  | .error e =>
    IO.eprintln s!"Parse error: {e}"
```

Output:
```
Alice is 30 years old, active: true
Bob is 25 years old, active: false
```

## Configuration

### Predefined Formats

```lean
-- CSV (comma-separated, default)
Tabular.parse csv Config.csv

-- TSV (tab-separated)
Tabular.parse tsv Config.tsv

-- PSV (pipe-separated)
Tabular.parse psv Config.psv

-- SCSV (semicolon-separated, European CSV)
Tabular.parse data Config.scsv
```

### Custom Configuration

```lean
-- Custom delimiter
let config := { Config.csv with delimiter := '|' }

-- No headers (access columns by index)
let config := { Config.csv with hasHeader := false }

-- Trim whitespace from unquoted fields
let config := { Config.csv with trimWhitespace := true }

-- Allow rows with fewer columns than header
let config := { Config.csv with allowRagged := true }
```

## API Reference

### Parsing

```lean
-- Parse with configuration (default: CSV)
def parse (input : String) (config : Config := Config.csv) : ParseResult Table

-- Parse without headers
def parseRows (input : String) (config : Config := Config.csv) : ParseResult (Array Row)

-- Convenience functions
def parseCsv (input : String) : ParseResult Table
def parseTsv (input : String) : ParseResult Table
```

### Table Access

```lean
-- Get row count
table.rowCount : Nat

-- Get column count
table.columnCount : Nat

-- Check if table has headers
table.hasHeaders : Bool

-- Get a specific row
table.row? (idx : Nat) : Option Row

-- Get all values in a column by index
table.column (idx : Nat) : Array Value

-- Get all values in a column by name
table.columnByName (name : String) : Array Value
```

### Row Extraction

```lean
-- By index
row.get? (idx : Nat) : Option Value
row.getAs [FromCsv α] (idx : Nat) : ExtractResult α

-- By name (case-insensitive)
row.getByName? (name : String) : Option Value
row.getByNameAs [FromCsv α] (name : String) : ExtractResult α

-- With Option for empty values
row.getAsOption [FromCsv α] (idx : Nat) : ExtractResult (Option α)
row.getByNameAsOption [FromCsv α] (name : String) : ExtractResult (Option α)
```

### Supported Types

The `FromCsv` typeclass has instances for:
- `String` - Raw cell content
- `Int` - Signed integers
- `Nat` - Non-negative integers (rejects negative values)
- `Float` - Floating point numbers (supports decimal notation)
- `Bool` - true/false, yes/no, y/n, 1/0
- `Option α` - Empty cells become `none`
- `Value` - Raw value passthrough

## Error Handling

### Parse Errors

```lean
inductive ParseError where
  | unexpectedChar (pos : Position) (char : Char) (expected : String)
  | unexpectedEnd (context : String)
  | unclosedQuote (pos : Position)
  | columnMismatch (pos : Position) (expected : Nat) (actual : Nat)
  | emptyInput
```

### Extraction Errors

```lean
inductive ExtractError where
  | typeConversion (value : String) (targetType : String)
  | columnNotFound (name : String)
  | indexOutOfBounds (index : Nat) (size : Nat)
  | emptyValue (column : String)
```

### Converting to IO

```lean
-- Convert ParseResult to IO
let table ← Tabular.parse csv |> Tabular.toIO

-- Convert ExtractResult to IO
let age ← row.getByNameAs (α := Int) "age" |> Tabular.toIO
```

## RFC 4180 Compliance

The parser follows RFC 4180 for CSV format:
- Fields may be enclosed in double quotes
- Embedded quotes are escaped by doubling (`""`)
- Embedded newlines are allowed within quoted fields
- CRLF, LF, or CR line endings are supported
- Trailing newline is optional

## License

MIT
