/-
  Rune - Sift Integration Tests
-/

import Rune
import Crucible
import Sift
import RuneTests.TestUtils

namespace RuneTests.SiftTests

open Crucible
open Sift
open Rune
open RuneTests

testSuite "Sift Integration"

-- ============================================================
-- regex combinator tests
-- ============================================================

test "regex matches at current position" := do
  let re := Regex.compile! "[a-z]+"
  match Parser.run (Rune.regex re) "hello" with
  | .ok result => result ≡ "hello"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex matches partial input" := do
  let re := Regex.compile! "[a-z]+"
  match Parser.runWithState (Rune.regex re) "hello123" with
  | .ok (result, state) =>
    result ≡ "hello"
    state.pos ≡ 5
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex fails when pattern doesn't match at position" := do
  let re := Regex.compile! "[a-z]+"
  match Parser.run (Rune.regex re) "123abc" with
  | .error _ => pure ()
  | .ok _ => throw (IO.userError "expected failure")

test "regex handles digits" := do
  let re := Regex.compile! "[0-9]+"
  match Parser.run (Rune.regex re) "12345" with
  | .ok result => result ≡ "12345"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex handles complex patterns" := do
  let re := Regex.compile! "[a-zA-Z_][a-zA-Z0-9_]*"
  match Parser.run (Rune.regex re) "my_var123" with
  | .ok result => result ≡ "my_var123"
  | .error e => throw (IO.userError s!"parse failed: {e}")

-- ============================================================
-- Position tracking tests
-- ============================================================

test "regex advances position correctly" := do
  let re := Regex.compile! "[a-z]+"
  match Parser.runWithState (Rune.regex re) "abc" with
  | .ok (_, state) =>
    state.pos ≡ 3
    state.line ≡ 1
    state.column ≡ 4
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex tracks newlines in matched text" := do
  let re := Regex.compile! "[a-z\n]+"
  match Parser.runWithState (Rune.regex re) "ab\ncd" with
  | .ok (result, state) =>
    result ≡ "ab\ncd"
    state.line ≡ 2
    state.column ≡ 3
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex tracks multiple newlines" := do
  let re := Regex.compile! "[^\t]+"
  match Parser.runWithState (Rune.regex re) "a\nb\nc" with
  | .ok (result, state) =>
    result ≡ "a\nb\nc"
    state.line ≡ 3
    state.column ≡ 2
  | .error e => throw (IO.userError s!"parse failed: {e}")

-- ============================================================
-- regexMatch combinator tests
-- ============================================================

test "regexMatch returns Match object" := do
  let re := Regex.compile! "[a-z]+"
  match Parser.run (regexMatch re) "hello" with
  | .ok m =>
    m.text ≡ "hello"
    m.start ≡ 0
    m.stop ≡ 5
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regexMatch captures groups" := do
  let re := Regex.compile! "([a-z]+)@([a-z]+)"
  match Parser.run (regexMatch re) "user@domain" with
  | .ok m =>
    m.text ≡ "user@domain"
    (m.group 1) ≡ some "user"
    (m.group 2) ≡ some "domain"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regexMatch with named captures" := do
  let re := Regex.compile! "(?<user>[a-z]+)@(?<host>[a-z]+)"
  match Parser.run (regexMatch re) "user@domain" with
  | .ok m =>
    (m.namedGroup "user") ≡ some "user"
    (m.namedGroup "host") ≡ some "domain"
  | .error e => throw (IO.userError s!"parse failed: {e}")

-- ============================================================
-- regexCaptures combinator tests
-- ============================================================

test "regexCaptures returns text and captures" := do
  let re := Regex.compile! "([a-z]+)@([a-z]+)"
  match Parser.run (regexCaptures re) "user@domain" with
  | .ok (text, captures) =>
    text ≡ "user@domain"
    captures.size ≡ 2
    captures[0]! ≡ some "user"
    captures[1]! ≡ some "domain"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regexCaptures with optional groups" := do
  let re := Regex.compile! "([a-z]+)(@([a-z]+))?"
  match Parser.run (regexCaptures re) "user" with
  | .ok (text, captures) =>
    text ≡ "user"
    captures.size ≡ 3
    captures[0]! ≡ some "user"
    captures[1]! ≡ none
    captures[2]! ≡ none
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regexCaptures with all groups matched" := do
  let re := Regex.compile! "([a-z]+)(@([a-z]+))?"
  match Parser.run (regexCaptures re) "user@domain" with
  | .ok (text, captures) =>
    text ≡ "user@domain"
    captures[0]! ≡ some "user"
    captures[1]! ≡ some "@domain"
    captures[2]! ≡ some "domain"
  | .error e => throw (IO.userError s!"parse failed: {e}")

-- ============================================================
-- Integration with Sift combinators
-- ============================================================

test "regex works with many" := do
  let re := Regex.compile! "[0-9]+"
  let p := many (Rune.regex re <* Sift.optional (char ','))
  match Parser.run p "123,456,789" with
  | .ok results =>
    results.size ≡ 3
    results[0]! ≡ "123"
    results[1]! ≡ "456"
    results[2]! ≡ "789"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex works with sepBy" := do
  let re := Regex.compile! "[a-z]+"
  let p := sepBy (Rune.regex re) (char ',')
  match Parser.run p "foo,bar,baz" with
  | .ok results =>
    results.size ≡ 3
    results[0]! ≡ "foo"
    results[1]! ≡ "bar"
    results[2]! ≡ "baz"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex works with sequence" := do
  let wordRe := Regex.compile! "[a-z]+"
  let numRe := Regex.compile! "[0-9]+"
  let p := do
    let word ← Rune.regex wordRe
    let _ ← char ':'
    let num ← Rune.regex numRe
    pure (word, num)
  match Parser.run p "count:42" with
  | .ok (word, num) =>
    word ≡ "count"
    num ≡ "42"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex works with alternative" := do
  let wordRe := Regex.compile! "[a-z]+"
  let numRe := Regex.compile! "[0-9]+"
  let p := attempt (Rune.regex numRe) <|> Rune.regex wordRe
  match Parser.run p "hello" with
  | .ok result => result ≡ "hello"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex works with attempt for backtracking" := do
  let wordRe := Regex.compile! "[a-z]+"
  let numRe := Regex.compile! "[0-9]+"
  let p := attempt (do
    let _ ← Rune.regex wordRe
    let _ ← char ':'
    Rune.regex numRe
  ) <|> Rune.regex wordRe
  -- First alternative fails (no colon), second succeeds
  match Parser.run p "hello" with
  | .ok result => result ≡ "hello"
  | .error e => throw (IO.userError s!"parse failed: {e}")

-- ============================================================
-- Edge cases
-- ============================================================

test "regex with empty match pattern" := do
  let re := Regex.compile! "[a-z]*"
  -- Matches empty string at start
  match Parser.runWithState (Rune.regex re) "123" with
  | .ok (result, state) =>
    result ≡ ""
    state.pos ≡ 0
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regex at end of input" := do
  let re := Regex.compile! "[a-z]+"
  let p := do
    let _ ← Sift.string "123"
    Rune.regex re
  match Parser.run p "123abc" with
  | .ok result => result ≡ "abc"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "regexCaptures with no capture groups" := do
  let re := Regex.compile! "[a-z]+"
  match Parser.run (regexCaptures re) "hello" with
  | .ok (text, captures) =>
    text ≡ "hello"
    captures.size ≡ 0
  | .error e => throw (IO.userError s!"parse failed: {e}")

end RuneTests.SiftTests
