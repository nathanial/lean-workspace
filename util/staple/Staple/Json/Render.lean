/-
  Staple.Json.Render - JSON rendering (serialization to string)

  Provides compact and pretty-printed output formats.
-/
import Staple.Json.Value

namespace Staple.Json

/-! ## String Escaping -/

/-- Escape a string for use as a JSON string value.
    Handles quotes, backslashes, and control characters per RFC 8259. -/
private def escapeJsonString (s : String) : String := Id.run do
  let mut result := ""
  for c in s.toList do
    if c == '"' then result := result ++ "\\\""
    else if c == '\\' then result := result ++ "\\\\"
    else if c == '\n' then result := result ++ "\\n"
    else if c == '\r' then result := result ++ "\\r"
    else if c == '\t' then result := result ++ "\\t"
    else if c.toNat < 32 then
      -- Unicode escape for control characters
      let hex := Nat.toDigits 16 c.toNat
      let padded := List.replicate (4 - hex.length) '0' ++ hex
      result := result ++ "\\u" ++ String.ofList padded
    else
      result := result.push c
  return result

namespace Value

/-! ## Compact Rendering -/

/-- Render a JSON value to a compact string with no extra whitespace. -/
partial def compress : Value → String
  | .null => "null"
  | .bool true => "true"
  | .bool false => "false"
  | .num n => n.toString
  | .str s => "\"" ++ escapeJsonString s ++ "\""
  | .arr items =>
    let inner := items.toList.map compress |> String.intercalate ","
    "[" ++ inner ++ "]"
  | .obj fields =>
    let inner := fields.toList.map (fun (k, v) => "\"" ++ escapeJsonString k ++ "\":" ++ compress v)
      |> String.intercalate ","
    "{" ++ inner ++ "}"

/-! ## Pretty Rendering -/

/-- Render a JSON value to a pretty-printed string with indentation.

    Parameters:
    - `indent`: number of spaces per indentation level (default 2)

    The output uses newlines and indentation for readability. -/
partial def pretty (indent : Nat := 2) : Value → String :=
  go 0
where
  go (level : Nat) : Value → String
    | .null => "null"
    | .bool true => "true"
    | .bool false => "false"
    | .num n => n.toString
    | .str s => "\"" ++ escapeJsonString s ++ "\""
    | .arr items =>
      if items.isEmpty then "[]"
      else
        let pad := String.ofList (List.replicate (indent * (level + 1)) ' ')
        let closePad := String.ofList (List.replicate (indent * level) ' ')
        let inner := items.toList.map (fun v => pad ++ go (level + 1) v)
          |> String.intercalate ",\n"
        "[\n" ++ inner ++ "\n" ++ closePad ++ "]"
    | .obj fields =>
      if fields.isEmpty then "{}"
      else
        let pad := String.ofList (List.replicate (indent * (level + 1)) ' ')
        let closePad := String.ofList (List.replicate (indent * level) ' ')
        let inner := fields.toList.map (fun (k, v) =>
            pad ++ "\"" ++ escapeJsonString k ++ "\": " ++ go (level + 1) v)
          |> String.intercalate ",\n"
        "{\n" ++ inner ++ "\n" ++ closePad ++ "}"

/-- Render with custom indentation string (e.g., tabs) -/
partial def prettyWith (indentStr : String := "  ") : Value → String :=
  go ""
where
  go (currentIndent : String) : Value → String
    | .null => "null"
    | .bool true => "true"
    | .bool false => "false"
    | .num n => n.toString
    | .str s => "\"" ++ escapeJsonString s ++ "\""
    | .arr items =>
      if items.isEmpty then "[]"
      else
        let nextIndent := currentIndent ++ indentStr
        let inner := items.toList.map (fun v => nextIndent ++ go nextIndent v)
          |> String.intercalate ",\n"
        "[\n" ++ inner ++ "\n" ++ currentIndent ++ "]"
    | .obj fields =>
      if fields.isEmpty then "{}"
      else
        let nextIndent := currentIndent ++ indentStr
        let inner := fields.toList.map (fun (k, v) =>
            nextIndent ++ "\"" ++ escapeJsonString k ++ "\": " ++ go nextIndent v)
          |> String.intercalate ",\n"
        "{\n" ++ inner ++ "\n" ++ currentIndent ++ "}"

instance : ToString Value := ⟨compress⟩

end Value

end Staple.Json
