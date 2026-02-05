/-
  Tests for Staple.String
-/
import Crucible
import Staple.String

namespace Tests.String

open Crucible
open Staple

testSuite "Staple.String"

test "containsSubstr - found" := do
  ("hello world".containsSubstr "world") ≡ true
  ("hello world".containsSubstr "hello") ≡ true
  ("hello world".containsSubstr " ") ≡ true

test "containsSubstr - not found" := do
  ("hello world".containsSubstr "foo") ≡ false
  ("hello world".containsSubstr "WORLD") ≡ false

test "containsSubstr - edge cases" := do
  -- Note: empty needle with splitOn-based impl has quirky behavior
  ("".containsSubstr "a") ≡ false
  ("abc".containsSubstr "abc") ≡ true

test "padLeft - basic" := do
  ("42".padLeft 5) ≡ "   42"
  ("42".padLeft 5 '0') ≡ "00042"

test "padLeft - no padding needed" := do
  ("hello".padLeft 3) ≡ "hello"
  ("hello".padLeft 5) ≡ "hello"

test "padRight - basic" := do
  ("42".padRight 5) ≡ "42   "
  ("42".padRight 5 '0') ≡ "42000"

test "padRight - no padding needed" := do
  ("hello".padRight 3) ≡ "hello"
  ("hello".padRight 5) ≡ "hello"

test "dropRightWhile" := do
  ("hello   ".dropRightWhile (· == ' ')) ≡ "hello"
  ("hello".dropRightWhile (· == ' ')) ≡ "hello"
  ("   ".dropRightWhile (· == ' ')) ≡ ""

test "dropLeftWhile" := do
  ("   hello".dropLeftWhile (· == ' ')) ≡ "hello"
  ("hello".dropLeftWhile (· == ' ')) ≡ "hello"
  ("   ".dropLeftWhile (· == ' ')) ≡ ""



end Tests.String
