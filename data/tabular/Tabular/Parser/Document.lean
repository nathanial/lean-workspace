/-
  Tabular.Parser.Document
  Full document parsing using Sift combinators
-/
import Sift
import Tabular.Parser.Record
import Tabular.Core.Table
import Tabular.Core.Error

namespace Tabular.Parser

open Sift
open Tabular

/-- Skip empty lines -/
partial def skipEmptyLines : Parser Unit Unit := do
  while true do
    match ← peek with
    | none => break
    | some c =>
      if isLineEnding c then
        let _ ← consumeLineEnding
      else
        break

/-- Parse entire CSV/TSV document -/
partial def parseDocument (config : Config) : Parser Unit Table := do
  -- Check for empty input
  if ← atEnd then
    return { headers := #[], rows := #[], config }

  -- Parse headers if configured
  let headers ← if config.hasHeader then
    parseHeaders config
  else
    pure #[]

  -- Parse data rows
  let mut rows : Array Row := #[]
  while !(← atEnd) do
    skipEmptyLines
    if ← atEnd then break

    let row ← parseRow config headers
    -- Skip empty rows (all fields empty)
    if row.values.any (fun v => !v.isEmpty) then
      -- Validate column count if headers present and not allowing ragged
      if !config.allowRagged && !headers.isEmpty && row.size != headers.size then
        let pos ← Parser.position
        Parser.fail s!"column mismatch: expected {headers.size}, got {row.size} at line {pos.line}"
      rows := rows.push row

    -- Consume line ending if present
    let _ ← consumeLineEnding

  return { headers, rows, config }

/-- Convert Sift ParseError to Tabular ParseError -/
private def toTabularError (e : Sift.ParseError) : ParseError :=
  .other ⟨e.pos.offset, e.pos.line, e.pos.column⟩ e.message

/-- Parse CSV/TSV from string -/
def parse (input : String) (config : Config := Config.csv) : ParseResult Table :=
  match Sift.Parser.run (parseDocument config) input with
  | .ok table => .ok table
  | .error e => .error (toTabularError e)

/-- Parse without headers -/
def parseRows (input : String) (config : Config := Config.csv) : ParseResult (Array Row) := do
  let table ← parse input { config with hasHeader := false }
  return table.rows

end Tabular.Parser
