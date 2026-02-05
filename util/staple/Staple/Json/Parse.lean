/-
  Staple.Json.Parse - JSON parser using Sift combinator library

  A parser for JSON per RFC 8259, built on the Sift parser combinator library.
-/
import Sift
import Staple.Json.Value

namespace Staple.Json

open Sift

/-- Skip JSON whitespace (space, tab, LF, CR) -/
private def jsonWs : Parser Unit Unit :=
  skipWhile (fun c => c == ' ' || c == '\t' || c == '\n' || c == '\r')

/-- Parse a JSON escape sequence after the backslash -/
private def parseEscape : Parser Unit Char := do
  let escaped ← anyChar
  match escaped with
  | 'n' => pure '\n'
  | 'r' => pure '\r'
  | 't' => pure '\t'
  | '"' => pure '"'
  | '\\' => pure '\\'
  | '/' => pure '/'
  | 'b' => pure '\x08'  -- backspace
  | 'f' => pure '\x0C'  -- form feed
  | 'u' => unicodeEscape4
  | c => Parser.fail s!"invalid escape sequence: \\{c}"

/-- Parse a JSON string literal -/
private partial def jsonString : Parser Unit String := do
  let _ ← char '"'
  let mut result := ""
  while (← peek) != some '"' do
    if ← atEnd then Parser.fail "unterminated string"
    let c ← anyChar
    if c == '\\' then
      result := result.push (← parseEscape)
    else
      result := result.push c
  let _ ← char '"'
  return result

/-- Parse a JSON number (integer or float) -/
private def jsonNumber : Parser Unit JsonNumber := do
  -- Optional minus sign
  let negative := (← Sift.optional (char '-')).isSome
  -- Integer part - first digit
  let firstDigit ← digit
  -- Collect remaining integer digits (if first wasn't 0)
  let intDigits ← if firstDigit == '0' then
    -- Leading zero must be alone (no 01, 007, etc.)
    pure #[firstDigit]
  else
    let rest ← many digit
    pure (#[firstDigit] ++ rest)
  let intPart := intDigits.foldl (fun acc c => acc * 10 + (c.toNat - '0'.toNat)) 0
  -- Fractional part
  let fracResult ← Sift.optional do
    let _ ← char '.'
    many1 digit
  let hasFrac := fracResult.isSome
  let fracDigits := fracResult.getD #[]
  -- Exponent part
  let expResult ← Sift.optional do
    let _ ← char 'e' <|> char 'E'
    let expSign ← Sift.optional (char '-' <|> char '+')
    let digits ← many1 digit
    pure (expSign == some '-', digits)
  let hasExp := expResult.isSome
  let (expNeg, expDigits) := expResult.getD (false, #[])

  if hasFrac || hasExp then
    -- Build float
    let intFloat := intPart.toFloat
    let fracFloat := if hasFrac then
      let (f, _) := fracDigits.foldl (fun (acc, div) c =>
        (acc + (c.toNat - '0'.toNat).toFloat / div, div * 10.0)) (0.0, 10.0)
      f
    else 0.0
    let base := intFloat + fracFloat
    let exp : Int := if hasExp then
      let e := expDigits.foldl (fun acc c => acc * 10 + (c.toNat - '0'.toNat)) 0
      if expNeg then -(e : Int) else (e : Int)
    else 0
    let result := if exp >= 0 then
      base * Float.pow 10 exp.toNat.toFloat
    else
      base / Float.pow 10 ((-exp).toNat).toFloat
    pure (.float (if negative then -result else result))
  else
    -- Integer
    let signedValue : Int := if negative then -(intPart : Int) else intPart
    pure (.int signedValue)

/-- Parse a JSON value -/
partial def parseValue : Parser Unit Value := do
  jsonWs
  let c ← peek
  match c with
  | some 'n' => let _ ← string "null"; pure .null
  | some 't' => let _ ← string "true"; pure (.bool true)
  | some 'f' => let _ ← string "false"; pure (.bool false)
  | some '"' => .str <$> jsonString
  | some '[' => parseArray
  | some '{' => parseObject
  | some c =>
    if c == '-' || c.isDigit then
      .num <$> jsonNumber
    else
      Parser.fail s!"unexpected character '{c}'"
  | none => Parser.fail "unexpected end of input"
where
  parseArray : Parser Unit Value := do
    let _ ← char '['
    jsonWs
    if (← peek) == some ']' then
      let _ ← char ']'
      return .arr #[]
    let mut items : Array Value := #[]
    repeat do
      let v ← parseValue
      items := items.push v
      jsonWs
      match ← peek with
      | some ',' =>
        let _ ← char ','
        jsonWs
      | some ']' => break
      | _ => Parser.fail "expected ',' or ']'"
    let _ ← char ']'
    return .arr items

  parseObject : Parser Unit Value := do
    let _ ← char '{'
    jsonWs
    if (← peek) == some '}' then
      let _ ← char '}'
      return .obj #[]
    let mut fields : Array (String × Value) := #[]
    repeat do
      jsonWs
      let key ← jsonString
      jsonWs
      let _ ← char ':'
      let value ← parseValue
      fields := fields.push (key, value)
      jsonWs
      match ← peek with
      | some ',' =>
        let _ ← char ','
        jsonWs
      | some '}' => break
      | _ => Parser.fail "expected ',' or '}'"
    let _ ← char '}'
    return .obj fields

/-- Parse a JSON string into a Value -/
def parse (input : String) : Except String Value :=
  match Parser.parse (parseValue <* jsonWs <* eof) input with
  | .ok v => .ok v
  | .error e => .error s!"JSON parse error at {e.pos.line}:{e.pos.column}: {e.message}"

/-- Parse a JSON string, returning Option -/
def parse? (input : String) : Option Value :=
  match parse input with
  | .ok v => some v
  | .error _ => none

end Staple.Json
