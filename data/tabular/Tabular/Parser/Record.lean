/-
  Tabular.Parser.Record
  Single record (row) parsing using Sift combinators
-/
import Sift
import Tabular.Parser.Field
import Tabular.Core.Row

namespace Tabular.Parser

open Sift
open Tabular

/-- Parse a single record (one row of fields) -/
partial def parseRecord (config : Config) : Parser Unit (Array Value) := do
  -- Handle empty line
  match ← peek with
  | none => return #[]
  | some c => if isLineEnding c then return #[]

  let mut fields : Array Value := #[]

  while true do
    let field ← parseField config
    fields := fields.push field

    match ← peek with
    | none => break
    | some c =>
      if c == config.delimiter then
        let _ ← anyChar  -- consume delimiter
        -- Continue to next field
      else if isLineEnding c then
        break
      else
        Parser.fail s!"expected delimiter or newline, got '{c}'"

  return fields

/-- Parse header row -/
def parseHeaders (config : Config) : Parser Unit (Array String) := do
  let values ← parseRecord config
  let _ ← consumeLineEnding  -- consume line ending after headers
  return values.map (·.content)

/-- Parse a data row with column index mapping -/
def parseRow (config : Config) (headers : Array String) : Parser Unit Row := do
  let values ← parseRecord config
  if headers.isEmpty then
    return Row.ofArray values
  else
    return Row.ofArrayWithHeaders values headers

end Tabular.Parser
