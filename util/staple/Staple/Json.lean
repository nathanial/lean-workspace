/-
  Staple.Json - JSON utilities

  This module provides:
  - JSON Value AST type with parsing and rendering
  - ToJsonStr typeclass for string-based serialization
  - jsonStr! macro for convenient JSON object creation

  Usage:
    -- Parse JSON
    let json := Staple.Json.parse "{\"name\": \"Alice\", \"age\": 30}"

    -- Build JSON values
    let obj := Value.mkObj #[("name", Value.str "Bob")]
    let compact := obj.compress  -- {"name":"Bob"}
    let pretty := obj.pretty     -- formatted with indentation

    -- Quick string serialization
    let columnId := 42
    jsonStr! { columnId }  -- {"columnId": 42}
-/
import Lean
import Staple.Json.Number
import Staple.Json.Value
import Staple.Json.Render
import Staple.Json.Parse
import Staple.Json.ToJson
import Staple.Json.FromJson
import Staple.Json.Naming

namespace Staple.Json

/-! ## JSON String Escaping -/

/-- Escape a string for use as a JSON string value.
    Handles quotes, backslashes, and control characters. -/
def escapeString (s : String) : String := Id.run do
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
      let padded := String.ofList (List.replicate (4 - hex.length) '0' ++ hex)
      result := result ++ "\\u" ++ padded
    else
      result := result.push c
  return result

/-! ## ToJsonStr Typeclass -/

/-- Typeclass for converting values to their JSON string representation.
    Unlike `ToJson`, this produces a raw string ready for embedding. -/
class ToJsonStr (α : Type) where
  toJsonStr : α → String

instance : ToJsonStr String where
  toJsonStr s := s!"\"{escapeString s}\""

instance : ToJsonStr Nat where
  toJsonStr n := toString n

instance : ToJsonStr Int where
  toJsonStr n := toString n

instance : ToJsonStr Bool where
  toJsonStr b := if b then "true" else "false"

instance : ToJsonStr Float where
  toJsonStr f := toString f

instance : ToJsonStr UInt64 where
  toJsonStr n := toString n.toNat

instance : ToJsonStr UInt8 where
  toJsonStr n := toString n.toNat

instance : ToJsonStr UInt16 where
  toJsonStr n := toString n.toNat

instance : ToJsonStr UInt32 where
  toJsonStr n := toString n.toNat

instance : ToJsonStr Int8 where
  toJsonStr n := toString n.toInt

instance : ToJsonStr Int16 where
  toJsonStr n := toString n.toInt

instance : ToJsonStr Int32 where
  toJsonStr n := toString n.toInt

instance : ToJsonStr Int64 where
  toJsonStr n := toString n.toInt

instance {α : Type} [ToJsonStr α] : ToJsonStr (Option α) where
  toJsonStr
    | none => "null"
    | some a => ToJsonStr.toJsonStr a

instance {α : Type} [ToJsonStr α] : ToJsonStr (Array α) where
  toJsonStr arr := "[" ++ (arr.toList.map ToJsonStr.toJsonStr |> String.intercalate ", ") ++ "]"

instance {α : Type} [ToJsonStr α] : ToJsonStr (List α) where
  toJsonStr lst := "[" ++ (lst.map ToJsonStr.toJsonStr |> String.intercalate ", ") ++ "]"

/-! ## JSON Object Builder -/

/-- Build a JSON object string from an array of key-value pairs.
    Values should already be formatted as JSON (e.g., strings quoted). -/
def buildJsonObject (fields : Array (String × String)) : String :=
  let inner := fields.toList.map (fun (k, v) => s!"\"{k}\": {v}")
    |> String.intercalate ", "
  s!"\{{inner}}"

/-! ## jsonStr! Macro -/

open Lean

/-- Syntax category for JSON fields in jsonStr! macro -/
declare_syntax_cat jsonField

/-- Shorthand field: `varName` (key inferred from identifier) -/
syntax ident : jsonField

/-- Explicit key field: `"key" : expr` -/
syntax str ":" term : jsonField

/-- Create a JSON object string with object literal syntax.

    Examples:
    ```
    let columnId := 42
    jsonStr! { columnId }                    -- {"columnId": 42}
    jsonStr! { "id" : columnId }             -- {"id": 42}
    jsonStr! { columnId, "name" : userName } -- {"columnId": 42, "name": "Alice"}
    ```
-/
syntax "jsonStr! " "{" jsonField,* "}" : term

macro_rules
  | `(jsonStr! { $fields,* }) => do
    let mut pairs : Array (TSyntax `term) := #[]
    for field in fields.getElems do
      match field with
      | `(jsonField| $key:str : $value:term) =>
        -- Explicit key: "key" : value
        pairs := pairs.push (← `(($key, ToJsonStr.toJsonStr $value)))
      | `(jsonField| $id:ident) =>
        -- Shorthand: varName (key = identifier name)
        let keyStr := Syntax.mkStrLit id.getId.toString
        pairs := pairs.push (← `(($keyStr, ToJsonStr.toJsonStr $id)))
      | _ => Macro.throwError "Invalid jsonStr! field syntax"
    `(Staple.Json.buildJsonObject #[$pairs,*])

end Staple.Json
