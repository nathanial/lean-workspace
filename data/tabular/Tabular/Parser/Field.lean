/-
  Tabular.Parser.Field
  Field/cell parsing with quote handling (RFC 4180 compliant)
  Built on Sift parser combinator library
-/
import Sift
import Tabular.Core.Config
import Tabular.Core.Value

namespace Tabular.Parser

open Sift
open Tabular

/-- Check if character is a line ending -/
def isLineEnding (c : Char) : Bool :=
  c == '\n' || c == '\r'

/-- Consume line ending (handles CRLF, LF, CR) -/
def consumeLineEnding : Parser Unit Bool := do
  match ← peek with
  | some '\r' =>
    let _ ← anyChar
    if (← peek) == some '\n' then let _ ← anyChar
    return true
  | some '\n' =>
    let _ ← anyChar
    return true
  | _ => return false

/-- Check if at field terminator (delimiter, newline, or EOF) -/
private def atFieldEnd (config : Config) : Parser Unit Bool := do
  match ← peek with
  | none => return true
  | some c => return c == config.delimiter || isLineEnding c

/-- Parse a quoted field (RFC 4180 compliant)
    - Fields enclosed in quote character
    - Embedded quotes escaped as "" (doubled)
    - Embedded newlines allowed -/
partial def parseQuotedField (config : Config) : Parser Unit Value := do
  let _ ← char config.quote

  let mut content := ""
  while true do
    if ← atEnd then Parser.fail "unclosed quote"
    let c ← anyChar
    if c == config.quote then
      -- Check for escaped quote ""
      if (← peek) == some config.quote then
        let _ ← anyChar
        content := content.push config.quote
      else
        -- End of quoted field
        break
    else
      content := content.push c

  return { content }

/-- Parse an unquoted field -/
partial def parseUnquotedField (config : Config) : Parser Unit Value := do
  let mut content := ""
  while !(← atFieldEnd config) do
    let c ← anyChar
    content := content.push c

  -- Optionally trim whitespace
  let finalContent := if config.trimWhitespace
    then content.trim
    else content
  return { content := finalContent }

/-- Parse a single field (quoted or unquoted) -/
def parseField (config : Config) : Parser Unit Value := do
  if config.trimWhitespace then
    skipWhile (fun c => c == ' ' || c == '\t')

  match ← peek with
  | none => return Value.empty
  | some c =>
    if c == config.quote then
      parseQuotedField config
    else if c == config.delimiter || isLineEnding c then
      return Value.empty
    else
      parseUnquotedField config

end Tabular.Parser
