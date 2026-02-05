/-
  Parser tests for Tabular
-/
import Crucible
import Tabular

open Crucible
open Tabular

namespace Tests.Parser

testSuite "CSV Parsing"

test "parse simple csv with headers" := do
  let csv := "name,age\nAlice,30\nBob,25"
  match parse csv with
  | .ok table =>
    ensure (table.headers == #["name", "age"]) "headers should match"
    ensure (table.rowCount == 2) "should have 2 rows"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse csv without headers" := do
  let csv := "Alice,30\nBob,25"
  let config := { Config.csv with hasHeader := false }
  match parse csv config with
  | .ok table =>
    ensure (table.headers.isEmpty) "should have no headers"
    ensure (table.rowCount == 2) "should have 2 rows"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse tsv" := do
  let tsv := "name\tage\nAlice\t30"
  match parse tsv Config.tsv with
  | .ok table =>
    ensure (table.headers == #["name", "age"]) "headers should match"
    ensure (table.rowCount == 1) "should have 1 row"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse quoted field" := do
  let csv := "name,desc\nAlice,\"Hello, World\""
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByName? "desc" with
      | some v => ensure (v.content == "Hello, World") "quoted field should be unquoted"
      | none => throw (IO.userError "desc column not found")
    | none => throw (IO.userError "no rows")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse escaped quotes" := do
  let csv := "name,desc\nAlice,\"She said \"\"hello\"\"\""
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByName? "desc" with
      | some v => ensure (v.content == "She said \"hello\"") "escaped quotes should be unescaped"
      | none => throw (IO.userError "desc column not found")
    | none => throw (IO.userError "no rows")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse empty fields" := do
  let csv := "a,b,c\n1,,3"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.get? 1 with
      | some v => ensure v.isEmpty "middle field should be empty"
      | none => throw (IO.userError "field 1 not found")
    | none => throw (IO.userError "no rows")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse embedded newline in quotes" := do
  let csv := "name,bio\nAlice,\"Line 1\nLine 2\""
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByName? "bio" with
      | some v => ensure (v.content.contains '\n') "should contain newline"
      | none => throw (IO.userError "bio column not found")
    | none => throw (IO.userError "no rows")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "parse custom delimiter" := do
  let psv := "name|age\nAlice|30"
  match parse psv Config.psv with
  | .ok table =>
    ensure (table.headers == #["name", "age"]) "headers should match"
    ensure (table.rowCount == 1) "should have 1 row"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "empty input" := do
  match parse "" with
  | .ok table =>
    ensure (table.rowCount == 0) "should have no rows"
    ensure (table.headers.isEmpty) "should have no headers"
  | .error _ => throw (IO.userError "empty input should not error")

test "single row no newline" := do
  let csv := "a,b,c"
  let config := { Config.csv with hasHeader := false }
  match parse csv config with
  | .ok table =>
    ensure (table.rowCount == 1) "should have 1 row"
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "whitespace trimming" := do
  let csv := "name,age\n  Alice  , 30 "
  let config := { Config.csv with trimWhitespace := true }
  match parse csv config with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByName? "name", row.getByName? "age" with
      | some n, some a =>
        ensure (n.content == "Alice") "name should be trimmed"
        ensure (a.content == "30") "age should be trimmed"
      | _, _ => throw (IO.userError "columns not found")
    | none => throw (IO.userError "no rows")
  | .error e => throw (IO.userError s!"parse failed: {e}")

end Tests.Parser
