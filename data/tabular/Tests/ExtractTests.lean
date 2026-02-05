/-
  Type extraction tests for Tabular
-/
import Crucible
import Tabular

open Crucible
open Tabular

namespace Tests.Extract

testSuite "Type Extraction"

test "extract string" := do
  let csv := "name\nAlice"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := String) "name" with
      | .ok s => s ≡ "Alice"
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract int" := do
  let csv := "value\n42"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Int) "value" with
      | .ok n => n ≡ 42
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract negative int" := do
  let csv := "value\n-17"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Int) "value" with
      | .ok n => n ≡ -17
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract nat" := do
  let csv := "value\n100"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Nat) "value" with
      | .ok n => n ≡ 100
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "nat rejects negative" := do
  let csv := "value\n-5"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Nat) "value" with
      | .ok _ => throw (IO.userError "expected error for negative nat")
      | .error (.typeConversion _ _) => ensure true "correct error type"
      | .error e => throw (IO.userError s!"unexpected error: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract float" := do
  let csv := "value\n3.14"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Float) "value" with
      | .ok f =>
        -- Check approximately equal
        ensure (f > 3.13 && f < 3.15) "float should be approximately 3.14"
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract int as float" := do
  let csv := "value\n42"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Float) "value" with
      | .ok f => ensure (f == 42.0) "int should convert to float"
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract bool true variants" := do
  let csv := "a,b,c,d\ntrue,1,yes,y"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getAs (α := Bool) 0,
            row.getAs (α := Bool) 1,
            row.getAs (α := Bool) 2,
            row.getAs (α := Bool) 3 with
      | .ok a, .ok b, .ok c, .ok d =>
        ensure (a && b && c && d) "all should be true"
      | _, _, _, _ => throw (IO.userError "extraction failed")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract bool false variants" := do
  let csv := "a,b,c,d\nfalse,0,no,n"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getAs (α := Bool) 0,
            row.getAs (α := Bool) 1,
            row.getAs (α := Bool) 2,
            row.getAs (α := Bool) 3 with
      | .ok a, .ok b, .ok c, .ok d =>
        ensure (!a && !b && !c && !d) "all should be false"
      | _, _, _, _ => throw (IO.userError "extraction failed")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract option for empty" := do
  -- Test with a row that has one non-empty and one empty column
  let csv := "name,value\nAlice,"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Option Int) "value" with
      | .ok none => ensure true "empty extracted as none"
      | .ok (some _) => throw (IO.userError "expected none")
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "extract option for value" := do
  let csv := "value\n42"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Option Int) "value" with
      | .ok (some n) => n ≡ 42
      | .ok none => throw (IO.userError "expected some")
      | .error e => throw (IO.userError s!"extraction failed: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "type conversion error" := do
  let csv := "value\nnot_a_number"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := Int) "value" with
      | .ok _ => throw (IO.userError "expected error")
      | .error (.typeConversion _ _) => ensure true "correct error type"
      | .error e => throw (IO.userError s!"unexpected error: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "column not found error" := do
  let csv := "name\nAlice"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := String) "nonexistent" with
      | .ok _ => throw (IO.userError "expected error")
      | .error (.columnNotFound _) => ensure true "correct error type"
      | .error e => throw (IO.userError s!"unexpected error: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "index out of bounds error" := do
  let csv := "a,b\n1,2"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getAs (α := Int) 5 with
      | .ok _ => throw (IO.userError "expected error")
      | .error (.indexOutOfBounds _ _) => ensure true "correct error type"
      | .error e => throw (IO.userError s!"unexpected error: {e}")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

test "case insensitive column names" := do
  let csv := "Name,AGE\nAlice,30"
  match parse csv with
  | .ok table =>
    match table.rows[0]? with
    | some row =>
      match row.getByNameAs (α := String) "name",
            row.getByNameAs (α := Int) "age" with
      | .ok n, .ok a =>
        ensure (n == "Alice") "name should match"
        ensure (a == 30) "age should match"
      | _, _ => throw (IO.userError "extraction failed")
    | none => throw (IO.userError "no row")
  | .error e => throw (IO.userError s!"parse failed: {e}")

end Tests.Extract
