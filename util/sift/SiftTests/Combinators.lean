import Crucible
import Sift

namespace SiftTests.Combinators

open Crucible
open Sift

testSuite "Combinators"

test "try backtracks on failure" := do
  let p := attempt (string "abc") <|> string "ab"
  match Parser.run p "ab" with
  | .ok s => s ≡ "ab"
  | .error _ => panic! "expected success"

test "orElse tries alternative on empty failure" := do
  let p := char 'a' <|> char 'b'
  match Parser.run p "b" with
  | .ok c => c ≡ 'b'
  | .error _ => panic! "expected success"

test "orElse does not try alternative after consuming" := do
  let p := string "abc" <|> string "ab"
  match Parser.run p "abd" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "choice selects first matching" := do
  let p := choice [string "foo", string "bar", string "baz"]
  match Parser.run p "bar" with
  | .ok s => s ≡ "bar"
  | .error _ => panic! "expected success"

test "optional returns some on match" := do
  match Parser.run (Sift.optional (char 'a')) "abc" with
  | .ok c => c ≡ some 'a'
  | .error _ => panic! "expected success"

test "optional returns none on no match" := do
  match Parser.run (Sift.optional (char 'a')) "bcd" with
  | .ok c => c ≡ none
  | .error _ => panic! "expected success"

test "many collects zero" := do
  match Parser.run (many digit) "abc" with
  | .ok arr => arr.size ≡ 0
  | .error _ => panic! "expected success"

test "many collects multiple" := do
  match Parser.run (many digit) "123abc" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '1'
    arr[1]! ≡ '2'
    arr[2]! ≡ '3'
  | .error _ => panic! "expected success"

test "many1 requires at least one" := do
  match Parser.run (many1 digit) "abc" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "many1 collects multiple" := do
  match Parser.run (many1 digit) "456xyz" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '4'
  | .error _ => panic! "expected success"

test "count parses exactly n" := do
  match Parser.run (count 3 digit) "12345" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '1'
    arr[2]! ≡ '3'
  | .error _ => panic! "expected success"

test "count fails if not enough" := do
  match Parser.run (count 5 digit) "123" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "sepBy parses separated values" := do
  match Parser.run (sepBy digit (char ',')) "1,2,3" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '1'
    arr[1]! ≡ '2'
    arr[2]! ≡ '3'
  | .error _ => panic! "expected success"

test "sepBy returns empty on no match" := do
  match Parser.run (sepBy digit (char ',')) "abc" with
  | .ok arr => arr.size ≡ 0
  | .error _ => panic! "expected success"

test "sepBy1 requires at least one" := do
  match Parser.run (sepBy1 digit (char ',')) "abc" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "between extracts middle" := do
  match Parser.run (between (char '(') (char ')') (many letter)) "(abc)" with
  | .ok arr => arr.size ≡ 3
  | .error _ => panic! "expected success"

test "chainl1 left associates" := do
  let num := natural
  let sub := char '-' *> pure (fun a b => a - b)
  match Parser.run (chainl1 num sub) "10-3-2" with
  | .ok n => n ≡ 5  -- (10 - 3) - 2 = 5
  | .error _ => panic! "expected success"

test "chainr1 right associates" := do
  let num := natural
  let pow := char '^' *> pure (fun a b => a ^ b)
  match Parser.run (chainr1 num pow) "2^3^2" with
  | .ok n => n ≡ 512  -- 2 ^ (3 ^ 2) = 2 ^ 9 = 512
  | .error _ => panic! "expected success"

test "notFollowedBy succeeds when parser fails" := do
  let p := string "if" <* notFollowedBy alphaNum
  match Parser.run p "if " with
  | .ok s => s ≡ "if"
  | .error _ => panic! "expected success"

test "notFollowedBy fails when parser succeeds" := do
  let p := string "if" <* notFollowedBy alphaNum
  match Parser.run p "iffy" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "lookAhead does not consume" := do
  let p := do
    let _ ← lookAhead (string "abc")
    string "ab"
  match Parser.run p "abc" with
  | .ok s => s ≡ "ab"
  | .error _ => panic! "expected success"

test "manyTill collects until end" := do
  let p := manyTill anyChar (string "END")
  match Parser.run p "abcEND" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ 'a'
  | .error _ => panic! "expected success"

test "label improves error message" := do
  let p := digit <?> "a digit"
  match Parser.run p "abc" with
  | .error e => shouldContainSubstr (toString e) "a digit"
  | .ok _ => panic! "expected failure"

-- Error Recovery Tests

test "recover handles success" := do
  let p := recover digit (fun _ => pure 'x')
  match Parser.run p "5" with
  | .ok c => c ≡ '5'
  | .error _ => panic! "expected success"

test "recover calls handler on failure" := do
  let p := recover digit (fun _ => pure 'x')
  match Parser.run p "abc" with
  | .ok c => c ≡ 'x'
  | .error _ => panic! "expected recovery"

test "recover passes error to handler" := do
  -- Handler receives the error and can inspect it
  let p := recover digit (fun e =>
    if e.message.isEmpty then pure 'E' else pure 'H')
  match Parser.run p "abc" with
  | .ok c => c ≡ 'H'  -- Handler was called with non-empty error message
  | .error _ => panic! "expected recovery"

test "recoverWith returns default on failure" := do
  let p := recoverWith natural 0
  match Parser.run p "abc" with
  | .ok n => n ≡ 0
  | .error _ => panic! "expected recovery"

test "recoverWith preserves success" := do
  let p := recoverWith natural 0
  match Parser.run p "42" with
  | .ok n => n ≡ 42
  | .error _ => panic! "expected success"

test "skipUntil finds sync point" := do
  let p := skipUntil (char ';')
  match Parser.run p "abc;def" with
  | .ok c => c ≡ ';'
  | .error _ => panic! "expected success"

test "skipUntil fails at eof" := do
  let p := skipUntil (char ';')
  match Parser.run p "abc" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "withRecovery syncs to delimiter" := do
  let p := withRecovery natural 0 (char ';')
  match Parser.run p "abc;123" with
  | .ok n => n ≡ 0
  | .error _ => panic! "expected recovery"

test "manyRecover collects valid items" := do
  let item := natural <* char ','
  let p := manyRecover item (char ',')
  match Parser.run p "1,2,x,3," with
  | .ok arr => arr.size ≡ 3  -- 1, 2, 3 (x skipped)
  | .error _ => panic! "expected success"

-- Permutation Tests

test "permute parses two in order" := do
  let pa : Parser Unit Char := char 'a'
  let pb : Parser Unit Char := char 'b'
  match Parser.run (permute (pa, pb)) "ab" with
  | .ok (a, b) =>
    a ≡ 'a'
    b ≡ 'b'
  | .error _ => panic! "expected success"

test "permute parses two reversed" := do
  let pa : Parser Unit Char := char 'a'
  let pb : Parser Unit Char := char 'b'
  match Parser.run (permute (pa, pb)) "ba" with
  | .ok (a, b) =>
    a ≡ 'a'
    b ≡ 'b'
  | .error _ => panic! "expected success"

test "permute fails on missing element" := do
  let pa : Parser Unit Char := char 'a'
  let pb : Parser Unit Char := char 'b'
  match Parser.run (permute (pa, pb)) "aa" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "permute parses three any order (cab)" := do
  let pa : Parser Unit Char := char 'a'
  let pb : Parser Unit Char := char 'b'
  let pc : Parser Unit Char := char 'c'
  match Parser.run (permute (pa, pb, pc)) "cab" with
  | .ok (a, b, c) =>
    a ≡ 'a'
    b ≡ 'b'
    c ≡ 'c'
  | .error _ => panic! "expected success"

test "permute parses three any order (bca)" := do
  let pa : Parser Unit Char := char 'a'
  let pb : Parser Unit Char := char 'b'
  let pc : Parser Unit Char := char 'c'
  match Parser.run (permute (pa, pb, pc)) "bca" with
  | .ok (a, b, c) =>
    a ≡ 'a'
    b ≡ 'b'
    c ≡ 'c'
  | .error _ => panic! "expected success"

test "permute parses four any order (dcba)" := do
  let pa : Parser Unit Char := char 'a'
  let pb : Parser Unit Char := char 'b'
  let pc : Parser Unit Char := char 'c'
  let pd : Parser Unit Char := char 'd'
  match Parser.run (permute (pa, pb, pc, pd)) "dcba" with
  | .ok (a, b, c, d) =>
    a ≡ 'a'
    b ≡ 'b'
    c ≡ 'c'
    d ≡ 'd'
  | .error _ => panic! "expected success"

test "permute with complex parsers" := do
  let pName : Parser Unit String := string "name:" *> spaces *> many1Chars letter <* spaces
  let pAge : Parser Unit Nat := string "age:" *> spaces *> natural <* spaces
  match Parser.run (permute (pName, pAge)) "age: 25 name: Alice" with
  | .ok (name, age) =>
    name ≡ "Alice"
    age ≡ 25
  | .error _ => panic! "expected success"

-- endBy / endBy1 Tests

test "endBy parses items ending with separator" := do
  match Parser.run (endBy digit (char ';')) "1;2;3;" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '1'
    arr[1]! ≡ '2'
    arr[2]! ≡ '3'
  | .error _ => panic! "expected success"

test "endBy returns empty on no match" := do
  match Parser.run (endBy digit (char ';')) "abc" with
  | .ok arr => arr.size ≡ 0
  | .error _ => panic! "expected success"

test "endBy1 requires at least one" := do
  match Parser.run (endBy1 digit (char ';')) "abc" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "endBy1 parses multiple" := do
  match Parser.run (endBy1 letter (char ';')) "a;b;c;" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ 'a'
    arr[1]! ≡ 'b'
    arr[2]! ≡ 'c'
  | .error _ => panic! "expected success"

-- sepEndBy / sepEndBy1 Tests

test "sepEndBy parses with trailing separator" := do
  match Parser.run (sepEndBy digit (char ',')) "1,2,3," with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '1'
    arr[1]! ≡ '2'
    arr[2]! ≡ '3'
  | .error _ => panic! "expected success"

test "sepEndBy parses without trailing separator" := do
  match Parser.run (sepEndBy digit (char ',')) "1,2,3" with
  | .ok arr =>
    arr.size ≡ 3
    arr[0]! ≡ '1'
    arr[1]! ≡ '2'
    arr[2]! ≡ '3'
  | .error _ => panic! "expected success"

test "sepEndBy returns empty on no match" := do
  match Parser.run (sepEndBy digit (char ',')) "abc" with
  | .ok arr => arr.size ≡ 0
  | .error _ => panic! "expected success"

test "sepEndBy1 with trailing separator" := do
  match Parser.run (sepEndBy1 letter (char ',')) "a,b," with
  | .ok arr =>
    arr.size ≡ 2
    arr[0]! ≡ 'a'
    arr[1]! ≡ 'b'
  | .error _ => panic! "expected success"

test "sepEndBy1 without trailing separator" := do
  match Parser.run (sepEndBy1 letter (char ',')) "a,b" with
  | .ok arr =>
    arr.size ≡ 2
    arr[0]! ≡ 'a'
    arr[1]! ≡ 'b'
  | .error _ => panic! "expected success"

test "sepEndBy1 requires at least one" := do
  match Parser.run (sepEndBy1 digit (char ',')) "," with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

-- skipMany / skipMany1 Tests

test "skipMany skips zero occurrences" := do
  let p := skipMany digit *> anyChar
  match Parser.run p "abc" with
  | .ok c => c ≡ 'a'
  | .error _ => panic! "expected success"

test "skipMany skips multiple" := do
  let p := skipMany digit *> anyChar
  match Parser.run p "123abc" with
  | .ok c => c ≡ 'a'
  | .error _ => panic! "expected success"

test "skipMany1 requires at least one" := do
  match Parser.run (skipMany1 digit) "abc" with
  | .error _ => pure ()
  | .ok _ => panic! "expected failure"

test "skipMany1 skips multiple" := do
  let p := skipMany1 digit *> anyChar
  match Parser.run p "123abc" with
  | .ok c => c ≡ 'a'
  | .error _ => panic! "expected success"

-- withFilter Tests

test "withFilter passes when predicate true" := do
  let p := withFilter natural (· > 10) "must be greater than 10"
  match Parser.run p "42" with
  | .ok n => n ≡ 42
  | .error _ => panic! "expected success"

test "withFilter fails when predicate false" := do
  let p := withFilter natural (· > 100) "must be greater than 100"
  match Parser.run p "42" with
  | .error e => shouldContainSubstr (toString e) "must be greater than 100"
  | .ok _ => panic! "expected failure"

-- Stress Tests

test "many handles deeply nested input" := do
  let longInput := String.ofList (List.replicate 1000 '5')
  match Parser.run (many digit) longInput with
  | .ok arr => arr.size ≡ 1000
  | .error _ => panic! "expected success"

test "sepBy handles long lists" := do
  let items := List.replicate 100 "1"
  let longInput := String.intercalate "," items
  match Parser.run (sepBy digit (char ',')) longInput with
  | .ok arr => arr.size ≡ 100
  | .error _ => panic! "expected success"

end SiftTests.Combinators
