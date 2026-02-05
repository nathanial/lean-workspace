/-
  Tabular - CSV/TSV Parser Library for Lean 4

  A configurable delimiter-separated values parser with typed column extraction.

  ## Quick Start

  ```lean
  import Tabular

  def main : IO Unit := do
    let csv := "name,age,active\nAlice,30,true\nBob,25,false"

    match Tabular.parse csv with
    | .ok table =>
      for row in table.rows do
        match row.getByNameAs (α := String) "name",
              row.getByNameAs (α := Int) "age",
              row.getByNameAs (α := Bool) "active" with
        | .ok name, .ok age, .ok active =>
          IO.println s!"{name} is {age} years old, active: {active}"
        | _, _, _ => IO.eprintln "extraction error"
    | .error e =>
      IO.eprintln s!"Parse error: {e}"
  ```

  ## TSV Parsing

  ```lean
  let tsv := "name\tage\nAlice\t30"
  let table ← Tabular.parse tsv Tabular.Config.tsv |> Tabular.toIO
  ```

  ## Configuration

  ```lean
  -- Custom delimiter
  let config := { Tabular.Config.csv with delimiter := '|' }

  -- No headers
  let config := { Tabular.Config.csv with hasHeader := false }

  -- Trim whitespace
  let config := { Tabular.Config.csv with trimWhitespace := true }
  ```
-/

-- Core types
import Tabular.Core.Config
import Tabular.Core.Value
import Tabular.Core.Row
import Tabular.Core.Table
import Tabular.Core.Error

-- Parser
import Tabular.Parser.Document

-- Type extraction
import Tabular.Extract

namespace Tabular

/-- Parse CSV/TSV from string with configuration -/
def parse (input : String) (config : Config := Config.csv) : ParseResult Table :=
  Parser.parse input config

/-- Parse CSV/TSV without treating first row as headers -/
def parseRows (input : String) (config : Config := Config.csv) : ParseResult (Array Row) :=
  Parser.parseRows input config

/-- Parse with default CSV configuration -/
def parseCsv (input : String) : ParseResult Table :=
  parse input Config.csv

/-- Parse with default TSV configuration -/
def parseTsv (input : String) : ParseResult Table :=
  parse input Config.tsv

/-- Helper to convert ExtractResult to IO -/
def ExtractResult.toIO (r : ExtractResult α) : IO α :=
  match r with
  | .ok a => pure a
  | .error e => throw (IO.userError (toString e))

/-- Helper to convert ParseResult to IO -/
def ParseResult.toIO (r : ParseResult α) : IO α :=
  match r with
  | .ok a => pure a
  | .error e => throw (IO.userError (toString e))

/-- Helper to convert any Except to IO -/
def toIO [ToString ε] (r : Except ε α) : IO α :=
  match r with
  | .ok a => pure a
  | .error e => throw (IO.userError (toString e))

end Tabular
