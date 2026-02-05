/-
  Tests for Staple.Hex
-/
import Crucible
import Staple.Hex

namespace StapleTests.Hex

open Crucible
open Staple.Hex

testSuite "Staple.Hex"

test "hexCharToNat - digits" := do
  (hexCharToNat '0') ≡ some 0
  (hexCharToNat '9') ≡ some 9

test "hexCharToNat - lowercase" := do
  (hexCharToNat 'a') ≡ some 10
  (hexCharToNat 'f') ≡ some 15

test "hexCharToNat - uppercase" := do
  (hexCharToNat 'A') ≡ some 10
  (hexCharToNat 'F') ≡ some 15

test "hexCharToNat - invalid" := do
  (hexCharToNat 'g') ≡ none
  (hexCharToNat 'z') ≡ none

test "nibbleToHexChar" := do
  (nibbleToHexChar 0) ≡ '0'
  (nibbleToHexChar 9) ≡ '9'
  (nibbleToHexChar 10) ≡ 'a'
  (nibbleToHexChar 15) ≡ 'f'

test "isHexDigit" := do
  (isHexDigit '0') ≡ true
  (isHexDigit 'a') ≡ true
  (isHexDigit 'F') ≡ true
  (isHexDigit 'g') ≡ false

test "uint8ToHex" := do
  (uint8ToHex 0) ≡ "00"
  (uint8ToHex 255) ≡ "ff"
  (uint8ToHex 171) ≡ "ab"

test "ByteArray.toHex" := do
  (ByteArray.mk #[0, 255, 171]).toHex ≡ "00ffab"

test "ByteArray.fromHex - valid" := do
  -- Compare via toHex round-trip since ByteArray lacks Repr
  ((ByteArray.fromHex "00ffab").map ByteArray.toHex) ≡ some "00ffab"

test "ByteArray.fromHex - invalid" := do
  (ByteArray.fromHex "0g").isNone ≡ true
  (ByteArray.fromHex "abc").isNone ≡ true  -- odd length



end StapleTests.Hex
