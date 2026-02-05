/-
  Tests for Staple.Ascii
-/
import Crucible
import Staple.Ascii

namespace Tests.Ascii

open Crucible
open Staple.Ascii

testSuite "Staple.Ascii"

test "isWhitespace" := do
  (isWhitespace ' ') ≡ true
  (isWhitespace '\t') ≡ true
  (isWhitespace '\n') ≡ true
  (isWhitespace 'a') ≡ false

test "isAlpha" := do
  (isAlpha 'a') ≡ true
  (isAlpha 'Z') ≡ true
  (isAlpha '0') ≡ false

test "isDigit" := do
  (isDigit '0') ≡ true
  (isDigit '9') ≡ true
  (isDigit 'a') ≡ false

test "isAlphaNum" := do
  (isAlphaNum 'a') ≡ true
  (isAlphaNum '5') ≡ true
  (isAlphaNum '-') ≡ false

test "isOctalDigit" := do
  (isOctalDigit '0') ≡ true
  (isOctalDigit '7') ≡ true
  (isOctalDigit '8') ≡ false

test "isBinaryDigit" := do
  (isBinaryDigit '0') ≡ true
  (isBinaryDigit '1') ≡ true
  (isBinaryDigit '2') ≡ false

test "isPrintable" := do
  (isPrintable ' ') ≡ true
  (isPrintable '~') ≡ true
  (isPrintable '\n') ≡ false

test "toLower" := do
  (toLower 'A') ≡ 'a'
  (toLower 'Z') ≡ 'z'
  (toLower 'a') ≡ 'a'
  (toLower '5') ≡ '5'

test "toUpper" := do
  (toUpper 'a') ≡ 'A'
  (toUpper 'z') ≡ 'Z'
  (toUpper 'A') ≡ 'A'

test "String.toLowerAscii" := do
  "HELLO".toLowerAscii ≡ "hello"
  "Hello World".toLowerAscii ≡ "hello world"

test "String.toUpperAscii" := do
  "hello".toUpperAscii ≡ "HELLO"

test "isDigitByte" := do
  (isDigitByte 48) ≡ true   -- '0'
  (isDigitByte 57) ≡ true   -- '9'
  (isDigitByte 65) ≡ false  -- 'A'

test "isAlphaByte" := do
  (isAlphaByte 65) ≡ true   -- 'A'
  (isAlphaByte 97) ≡ true   -- 'a'
  (isAlphaByte 48) ≡ false  -- '0'



end Tests.Ascii
