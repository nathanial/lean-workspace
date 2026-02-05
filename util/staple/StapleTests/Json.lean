/-
  Tests for Staple.Json
-/
import Crucible
import Staple.Json
import Staple.Json.Value
import Staple.Json.Render
import Staple.Json.Parse
import Staple.Json.ToJson
import Staple.Json.FromJson

namespace StapleTests.Json

open Crucible
open Staple.Json

testSuite "Staple.Json"

test "escapeString - no escaping" := do
  (escapeString "hello") ≡ "hello"
  (escapeString "abc123") ≡ "abc123"

test "escapeString - quotes" := do
  (escapeString "say \"hi\"") ≡ "say \\\"hi\\\""

test "escapeString - backslash" := do
  (escapeString "a\\b") ≡ "a\\\\b"

test "escapeString - control chars" := do
  (escapeString "line\nbreak") ≡ "line\\nbreak"
  (escapeString "tab\there") ≡ "tab\\there"
  (escapeString "return\rhere") ≡ "return\\rhere"

test "ToJsonStr - String" := do
  (ToJsonStr.toJsonStr "hello") ≡ "\"hello\""
  (ToJsonStr.toJsonStr "") ≡ "\"\""

test "ToJsonStr - Nat" := do
  (ToJsonStr.toJsonStr (0 : Nat)) ≡ "0"
  (ToJsonStr.toJsonStr (42 : Nat)) ≡ "42"

test "ToJsonStr - Int" := do
  (ToJsonStr.toJsonStr (42 : Int)) ≡ "42"
  (ToJsonStr.toJsonStr (-42 : Int)) ≡ "-42"

test "ToJsonStr - Bool" := do
  (ToJsonStr.toJsonStr true) ≡ "true"
  (ToJsonStr.toJsonStr false) ≡ "false"

test "ToJsonStr - Option" := do
  (ToJsonStr.toJsonStr (some 42 : Option Nat)) ≡ "42"
  (ToJsonStr.toJsonStr (none : Option Nat)) ≡ "null"

test "ToJsonStr - Array" := do
  (ToJsonStr.toJsonStr #[1, 2, 3]) ≡ "[1, 2, 3]"
  (ToJsonStr.toJsonStr (#[] : Array Nat)) ≡ "[]"

test "ToJsonStr - List" := do
  (ToJsonStr.toJsonStr [1, 2, 3]) ≡ "[1, 2, 3]"
  (ToJsonStr.toJsonStr ([] : List Nat)) ≡ "[]"

test "ToJsonStr - UInt8" := do
  (ToJsonStr.toJsonStr (255 : UInt8)) ≡ "255"
  (ToJsonStr.toJsonStr (0 : UInt8)) ≡ "0"

test "jsonStr! - shorthand" := do
  let name := "Alice"
  let age : Nat := 30
  (jsonStr! { name, age }) ≡ "{\"name\": \"Alice\", \"age\": 30}"

test "jsonStr! - explicit keys" := do
  let x : Nat := 10
  (jsonStr! { "value" : x }) ≡ "{\"value\": 10}"

test "jsonStr! - mixed" := do
  let name := "Bob"
  let score : Nat := 100
  (jsonStr! { name, "points" : score }) ≡ "{\"name\": \"Bob\", \"points\": 100}"

/-! ## JsonNumber Tests -/

test "JsonNumber - int creation" := do
  (JsonNumber.fromInt 42).toString ≡ "42"
  (JsonNumber.fromInt (-5)).toString ≡ "-5"
  (JsonNumber.fromNat 100).toString ≡ "100"

test "JsonNumber - float creation" := do
  (JsonNumber.fromFloat 3.14).isInt ≡ false

test "JsonNumber - toInt/toNat" := do
  (JsonNumber.fromInt 42).toInt ≡ 42
  (JsonNumber.fromInt 42).toNat ≡ 42

/-! ## Value Construction Tests -/

test "Value.mkStr" := do
  Value.mkStr "hello" ≡ Value.str "hello"

test "Value.mkInt" := do
  Value.mkInt 42 ≡ Value.num (JsonNumber.int 42)

test "Value.mkBool" := do
  Value.mkBool true ≡ Value.bool true
  Value.mkBool false ≡ Value.bool false

test "Value.mkArr" := do
  Value.mkArr #[Value.null, Value.bool true] ≡ Value.arr #[Value.null, Value.bool true]

test "Value.mkObj" := do
  let obj := Value.mkObj #[("a", Value.mkInt 1)]
  obj.isObj ≡ true

/-! ## Value Accessor Tests -/

test "Value.getBool?" := do
  (Value.bool true).getBool? ≡ some true
  Value.null.getBool? ≡ none

test "Value.getStr?" := do
  (Value.str "test").getStr? ≡ some "test"
  Value.null.getStr? ≡ none

test "Value.getNat?" := do
  (Value.num (JsonNumber.int 42)).getNat? ≡ some 42
  (Value.num (JsonNumber.int (-1))).getNat? ≡ none

test "Value.getArr?" := do
  (Value.arr #[]).getArr? ≡ some #[]
  Value.null.getArr? ≡ none

test "Value.getField?" := do
  let obj := Value.mkObj #[("name", Value.str "Alice"), ("age", Value.mkInt 30)]
  obj.getField? "name" ≡ some (Value.str "Alice")
  obj.getField? "missing" ≡ none

test "Value.getStrField?" := do
  let obj := Value.mkObj #[("name", Value.str "Bob")]
  obj.getStrField? "name" ≡ some "Bob"

/-! ## Value.compress Tests -/

test "compress - null" := do
  Value.null.compress ≡ "null"

test "compress - bool" := do
  (Value.bool true).compress ≡ "true"
  (Value.bool false).compress ≡ "false"

test "compress - number" := do
  (Value.mkInt 42).compress ≡ "42"
  (Value.mkInt (-5)).compress ≡ "-5"

test "compress - string" := do
  (Value.str "hello").compress ≡ "\"hello\""
  (Value.str "say \"hi\"").compress ≡ "\"say \\\"hi\\\"\""

test "compress - array" := do
  (Value.arr #[]).compress ≡ "[]"
  (Value.arr #[Value.mkInt 1, Value.mkInt 2]).compress ≡ "[1,2]"

test "compress - object" := do
  (Value.obj #[]).compress ≡ "{}"
  (Value.mkObj #[("a", Value.mkInt 1)]).compress ≡ "{\"a\":1}"

test "compress - nested" := do
  let nested := Value.mkObj #[
    ("items", Value.arr #[Value.mkInt 1, Value.mkInt 2]),
    ("name", Value.str "test")
  ]
  nested.compress ≡ "{\"items\":[1,2],\"name\":\"test\"}"

/-! ## Value.pretty Tests -/

test "pretty - simple values" := do
  Value.null.pretty ≡ "null"
  (Value.bool true).pretty ≡ "true"
  (Value.mkInt 42).pretty ≡ "42"
  (Value.str "hi").pretty ≡ "\"hi\""

test "pretty - empty containers" := do
  (Value.arr #[]).pretty ≡ "[]"
  (Value.obj #[]).pretty ≡ "{}"

test "pretty - array formatting" := do
  let arr := Value.arr #[Value.mkInt 1, Value.mkInt 2]
  arr.pretty ≡ "[\n  1,\n  2\n]"

test "pretty - object formatting" := do
  let obj := Value.mkObj #[("a", Value.mkInt 1)]
  obj.pretty ≡ "{\n  \"a\": 1\n}"

/-! ## Parser Tests -/

test "parse - null" := do
  match parse "null" with
  | .ok v => v ≡ Value.null
  | .error _ => throwThe IO.Error "parse failed"
  match parse "  null  " with
  | .ok v => v ≡ Value.null
  | .error _ => throwThe IO.Error "parse failed"

test "parse - bool" := do
  match parse "true" with
  | .ok v => v ≡ Value.bool true
  | .error _ => throwThe IO.Error "parse failed"
  match parse "false" with
  | .ok v => v ≡ Value.bool false
  | .error _ => throwThe IO.Error "parse failed"

test "parse - integer" := do
  match parse "42" with
  | .ok v => v ≡ Value.num (JsonNumber.int 42)
  | .error _ => throwThe IO.Error "parse failed"
  match parse "-5" with
  | .ok v => v ≡ Value.num (JsonNumber.int (-5))
  | .error _ => throwThe IO.Error "parse failed"

test "parse - string" := do
  match parse "\"hello\"" with
  | .ok v => v ≡ Value.str "hello"
  | .error _ => throwThe IO.Error "parse failed"
  match parse "\"\"" with
  | .ok v => v ≡ Value.str ""
  | .error _ => throwThe IO.Error "parse failed"

test "parse - string escapes" := do
  match parse "\"a\\nb\"" with
  | .ok v => v ≡ Value.str "a\nb"
  | .error _ => throwThe IO.Error "parse failed"
  match parse "\"a\\tb\"" with
  | .ok v => v ≡ Value.str "a\tb"
  | .error _ => throwThe IO.Error "parse failed"

test "parse - array" := do
  match parse "[]" with
  | .ok v => v ≡ Value.arr #[]
  | .error _ => throwThe IO.Error "parse failed"
  match parse "[1, 2, 3]" with
  | .ok v => v ≡ Value.arr #[
      Value.num (JsonNumber.int 1),
      Value.num (JsonNumber.int 2),
      Value.num (JsonNumber.int 3)
    ]
  | .error _ => throwThe IO.Error "parse failed"

test "parse - object" := do
  match parse "{}" with
  | .ok v => v ≡ Value.obj #[]
  | .error _ => throwThe IO.Error "parse failed"
  match parse "{\"a\": 1}" with
  | .ok v => v ≡ Value.mkObj #[("a", Value.num (JsonNumber.int 1))]
  | .error _ => throwThe IO.Error "parse failed"

test "parse - nested" := do
  let input := "{\"items\": [1, 2], \"active\": true}"
  match parse input with
  | .ok v => do
    (v.getArrField? "items" |>.isSome) ≡ true
    v.getBoolField? "active" ≡ some true
  | .error _ =>
    throwThe IO.Error "Expected successful parse"

test "parse - whitespace tolerance" := do
  match parse "  {  \"a\"  :  1  }  " with
  | .ok v => v ≡ Value.mkObj #[("a", Value.num (JsonNumber.int 1))]
  | .error _ => throwThe IO.Error "parse failed"

/-! ## Round-trip Tests -/

test "round-trip - simple values" := do
  let values := #[
    Value.null,
    Value.bool true,
    Value.bool false,
    Value.mkInt 42,
    Value.mkInt (-100),
    Value.str "hello",
    Value.str "with \"quotes\""
  ]
  for v in values do
    match parse v.compress with
    | .ok parsed => parsed ≡ v
    | .error e => throwThe IO.Error s!"Round-trip failed: {e}"

test "round-trip - containers" := do
  let arr := Value.arr #[Value.mkInt 1, Value.str "two", Value.null]
  match parse arr.compress with
  | .ok parsed => parsed ≡ arr
  | .error e => throwThe IO.Error s!"Array round-trip failed: {e}"

  let obj := Value.mkObj #[("name", Value.str "test"), ("count", Value.mkInt 5)]
  match parse obj.compress with
  | .ok parsed => parsed ≡ obj
  | .error e => throwThe IO.Error s!"Object round-trip failed: {e}"

/-! ## Error Handling Tests -/

test "parse - invalid input" := do
  (parse "invalid" |>.isOk) ≡ false
  (parse "{" |>.isOk) ≡ false
  (parse "[1,]" |>.isOk) ≡ false

test "parse - trailing content" := do
  (parse "null extra" |>.isOk) ≡ false

/-! ## ToJson Tests -/

test "ToJson - Bool" := do
  (toJson true).compress ≡ "true"
  (toJson false).compress ≡ "false"

test "ToJson - Nat" := do
  (toJson (42 : Nat)).compress ≡ "42"
  (toJson (0 : Nat)).compress ≡ "0"

test "ToJson - Int" := do
  (toJson (42 : Int)).compress ≡ "42"
  (toJson (-42 : Int)).compress ≡ "-42"

test "ToJson - String" := do
  (toJson "hello").compress ≡ "\"hello\""
  (toJson "").compress ≡ "\"\""

test "ToJson - Option" := do
  (toJson (some 42 : Option Nat)).compress ≡ "42"
  (toJson (none : Option Nat)).compress ≡ "null"

test "ToJson - Array" := do
  (toJson #[1, 2, 3]).compress ≡ "[1,2,3]"
  (toJson (#[] : Array Nat)).compress ≡ "[]"

test "ToJson - List" := do
  (toJson [1, 2, 3]).compress ≡ "[1,2,3]"

test "ToJson - Tuple" := do
  (toJson (1, "two")).compress ≡ "[1,\"two\"]"

test "ToJson - toJsonString" := do
  toJsonString (42 : Nat) ≡ "42"
  toJsonString "hello" ≡ "\"hello\""

/-! ## FromJson Tests -/

test "FromJson - Bool" := do
  (fromJson? (Value.bool true) : Option Bool) ≡ some true
  (fromJson? (Value.bool false) : Option Bool) ≡ some false

test "FromJson - Nat" := do
  (fromJson? (Value.mkInt 42) : Option Nat) ≡ some 42
  (fromJson? (Value.mkInt (-1)) : Option Nat) ≡ none  -- negative

test "FromJson - Int" := do
  (fromJson? (Value.mkInt 42) : Option Int) ≡ some 42
  (fromJson? (Value.mkInt (-42)) : Option Int) ≡ some (-42)

test "FromJson - String" := do
  (fromJson? (Value.str "hello") : Option String) ≡ some "hello"

test "FromJson - Option" := do
  (fromJson? Value.null : Option (Option Nat)) ≡ some none
  (fromJson? (Value.mkInt 42) : Option (Option Nat)) ≡ some (some 42)

test "FromJson - Array" := do
  match fromJson? (Value.arr #[Value.mkInt 1, Value.mkInt 2]) with
  | some (arr : Array Nat) => arr ≡ #[1, 2]
  | none => throwThe IO.Error "parse failed"

test "FromJson - List" := do
  match fromJson? (Value.arr #[Value.mkInt 1, Value.mkInt 2]) with
  | some (lst : List Nat) => lst ≡ [1, 2]
  | none => throwThe IO.Error "parse failed"

test "FromJson - Tuple" := do
  match fromJson? (Value.arr #[Value.mkInt 1, Value.str "two"]) with
  | some (p : Nat × String) => do
    p.1 ≡ 1
    p.2 ≡ "two"
  | none => throwThe IO.Error "parse failed"

/-! ## Round-trip ToJson/FromJson Tests -/

test "ToJson/FromJson round-trip - primitives" := do
  -- Bool
  let b := true
  (fromJson? (toJson b) : Option Bool) ≡ some b

  -- Nat
  let n : Nat := 42
  (fromJson? (toJson n) : Option Nat) ≡ some n

  -- Int
  let i : Int := -100
  (fromJson? (toJson i) : Option Int) ≡ some i

  -- String
  let s := "hello world"
  (fromJson? (toJson s) : Option String) ≡ some s

test "ToJson/FromJson round-trip - containers" := do
  -- Array
  let arr : Array Nat := #[1, 2, 3]
  (fromJson? (toJson arr) : Option (Array Nat)) ≡ some arr

  -- List
  let lst : List Nat := [1, 2, 3]
  (fromJson? (toJson lst) : Option (List Nat)) ≡ some lst

  -- Option
  let opt : Option Nat := some 42
  (fromJson? (toJson opt) : Option (Option Nat)) ≡ some opt

test "fromJsonString? - parse and convert" := do
  (fromJsonString? "42" : Option Nat) ≡ some 42
  (fromJsonString? "\"hello\"" : Option String) ≡ some "hello"
  (fromJsonString? "[1,2,3]" : Option (Array Nat)) ≡ some #[1, 2, 3]

/-! ## FieldNaming Tests -/

test "splitWords - camelCase" := do
  FieldNaming.splitWords "firstName" ≡ ["first", "Name"]
  FieldNaming.splitWords "lastName" ≡ ["last", "Name"]
  FieldNaming.splitWords "getUserById" ≡ ["get", "User", "By", "Id"]

test "splitWords - snake_case" := do
  FieldNaming.splitWords "first_name" ≡ ["first", "name"]
  FieldNaming.splitWords "last_name" ≡ ["last", "name"]
  FieldNaming.splitWords "get_user_by_id" ≡ ["get", "user", "by", "id"]

test "splitWords - kebab-case" := do
  FieldNaming.splitWords "first-name" ≡ ["first", "name"]
  FieldNaming.splitWords "get-user-by-id" ≡ ["get", "user", "by", "id"]

test "splitWords - PascalCase" := do
  FieldNaming.splitWords "FirstName" ≡ ["First", "Name"]
  FieldNaming.splitWords "GetUserById" ≡ ["Get", "User", "By", "Id"]

test "splitWords - acronyms" := do
  FieldNaming.splitWords "XMLParser" ≡ ["XML", "Parser"]
  FieldNaming.splitWords "parseXML" ≡ ["parse", "XML"]
  FieldNaming.splitWords "HTMLElement" ≡ ["HTML", "Element"]

test "splitWords - with numbers" := do
  FieldNaming.splitWords "user123" ≡ ["user", "123"]
  FieldNaming.splitWords "v2Api" ≡ ["v", "2", "Api"]
  FieldNaming.splitWords "int64Value" ≡ ["int", "64", "Value"]

test "splitWords - edge cases" := do
  FieldNaming.splitWords "" ≡ []
  FieldNaming.splitWords "x" ≡ ["x"]
  FieldNaming.splitWords "X" ≡ ["X"]
  FieldNaming.splitWords "id" ≡ ["id"]

test "toCamelCase - from snake_case" := do
  FieldNaming.toCamelCase "first_name" ≡ "firstName"
  FieldNaming.toCamelCase "last_name" ≡ "lastName"
  FieldNaming.toCamelCase "get_user_by_id" ≡ "getUserById"
  FieldNaming.toCamelCase "blocked_by" ≡ "blockedBy"

test "toCamelCase - from kebab-case" := do
  FieldNaming.toCamelCase "first-name" ≡ "firstName"
  FieldNaming.toCamelCase "content-type" ≡ "contentType"

test "toCamelCase - from PascalCase" := do
  FieldNaming.toCamelCase "FirstName" ≡ "firstName"
  FieldNaming.toCamelCase "GetUserById" ≡ "getUserById"

test "toCamelCase - from SCREAMING_SNAKE" := do
  FieldNaming.toCamelCase "FIRST_NAME" ≡ "firstName"
  FieldNaming.toCamelCase "MAX_RETRIES" ≡ "maxRetries"

test "toCamelCase - preserves camelCase" := do
  FieldNaming.toCamelCase "firstName" ≡ "firstName"
  FieldNaming.toCamelCase "getUserById" ≡ "getUserById"

test "toSnakeCase - from camelCase" := do
  FieldNaming.toSnakeCase "firstName" ≡ "first_name"
  FieldNaming.toSnakeCase "lastName" ≡ "last_name"
  FieldNaming.toSnakeCase "getUserById" ≡ "get_user_by_id"
  FieldNaming.toSnakeCase "blockedBy" ≡ "blocked_by"

test "toSnakeCase - from PascalCase" := do
  FieldNaming.toSnakeCase "FirstName" ≡ "first_name"
  FieldNaming.toSnakeCase "GetUserById" ≡ "get_user_by_id"

test "toSnakeCase - from kebab-case" := do
  FieldNaming.toSnakeCase "first-name" ≡ "first_name"
  FieldNaming.toSnakeCase "content-type" ≡ "content_type"

test "toSnakeCase - acronyms" := do
  FieldNaming.toSnakeCase "XMLParser" ≡ "xml_parser"
  FieldNaming.toSnakeCase "parseXML" ≡ "parse_xml"
  FieldNaming.toSnakeCase "htmlElement" ≡ "html_element"

test "toKebabCase - from camelCase" := do
  FieldNaming.toKebabCase "firstName" ≡ "first-name"
  FieldNaming.toKebabCase "getUserById" ≡ "get-user-by-id"

test "toKebabCase - from snake_case" := do
  FieldNaming.toKebabCase "first_name" ≡ "first-name"
  FieldNaming.toKebabCase "get_user_by_id" ≡ "get-user-by-id"

test "toKebabCase - from PascalCase" := do
  FieldNaming.toKebabCase "FirstName" ≡ "first-name"

test "toScreamingSnake - from camelCase" := do
  FieldNaming.toScreamingSnake "firstName" ≡ "FIRST_NAME"
  FieldNaming.toScreamingSnake "maxRetries" ≡ "MAX_RETRIES"

test "toScreamingSnake - from snake_case" := do
  FieldNaming.toScreamingSnake "first_name" ≡ "FIRST_NAME"
  FieldNaming.toScreamingSnake "max_retries" ≡ "MAX_RETRIES"

test "toPascalCase - from camelCase" := do
  FieldNaming.toPascalCase "firstName" ≡ "FirstName"
  FieldNaming.toPascalCase "getUserById" ≡ "GetUserById"

test "toPascalCase - from snake_case" := do
  FieldNaming.toPascalCase "first_name" ≡ "FirstName"
  FieldNaming.toPascalCase "get_user_by_id" ≡ "GetUserById"

test "FieldNaming.apply - preserve" := do
  FieldNaming.apply .preserve "firstName" ≡ "firstName"
  FieldNaming.apply .preserve "first_name" ≡ "first_name"

test "FieldNaming.apply - all conventions" := do
  let name := "blockedBy"
  FieldNaming.apply .preserve name ≡ "blockedBy"
  FieldNaming.apply .camelCase name ≡ "blockedBy"
  FieldNaming.apply .snakeCase name ≡ "blocked_by"
  FieldNaming.apply .kebabCase name ≡ "blocked-by"
  FieldNaming.apply .screamingSnake name ≡ "BLOCKED_BY"

test "FieldNaming.normalize" := do
  FieldNaming.normalize "firstName" ≡ "firstname"
  FieldNaming.normalize "first_name" ≡ "firstname"
  FieldNaming.normalize "first-name" ≡ "firstname"
  FieldNaming.normalize "FIRST_NAME" ≡ "firstname"

test "FieldNaming.namesMatch" := do
  (FieldNaming.namesMatch "firstName" "first_name") ≡ true
  (FieldNaming.namesMatch "firstName" "first-name") ≡ true
  (FieldNaming.namesMatch "firstName" "FIRST_NAME") ≡ true
  (FieldNaming.namesMatch "blockedBy" "blocked_by") ≡ true
  (FieldNaming.namesMatch "firstName" "lastName") ≡ false



end StapleTests.Json
