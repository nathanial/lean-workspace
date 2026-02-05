/-
  Staple.Hex - Hex encoding/decoding utilities

  Provides functions for converting between hex strings and binary data.
  Supports both Char-based (for string parsing) and UInt8-based (for byte parsing) operations.
-/

namespace Staple.Hex

/-- Convert a hex character ('0'-'9', 'a'-'f', 'A'-'F') to its numeric value (0-15).
    Returns `none` for invalid hex characters. -/
def hexCharToNat (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c && c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c && c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

/-- Check if a character is a valid hex digit. -/
def isHexDigit (c : Char) : Bool :=
  ('0' ≤ c && c ≤ '9') || ('a' ≤ c && c ≤ 'f') || ('A' ≤ c && c ≤ 'F')

/-- Convert a value 0-15 to its lowercase hex character.
    Values >= 16 will produce incorrect results. -/
def nibbleToHexChar (n : Nat) : Char :=
  if n < 10 then Char.ofNat ('0'.toNat + n)
  else Char.ofNat ('a'.toNat + n - 10)

/-- Parse two hex characters as a byte.
    Returns `none` if either character is invalid. -/
def hexPairToUInt8 (hi lo : Char) : Option UInt8 := do
  let h ← hexCharToNat hi
  let l ← hexCharToNat lo
  some (h * 16 + l).toUInt8

/-- Encode a byte as two lowercase hex characters. -/
def uint8ToHex (b : UInt8) : String :=
  let hi := nibbleToHexChar (b.toNat / 16)
  let lo := nibbleToHexChar (b.toNat % 16)
  String.singleton hi ++ String.singleton lo

/-- Encode a ByteArray as a lowercase hex string. -/
def _root_.ByteArray.toHex (bytes : ByteArray) : String :=
  bytes.foldl (fun acc b => acc ++ uint8ToHex b) ""

/-- Decode a hex string to a ByteArray.
    Returns `none` if the string has odd length or contains invalid hex characters. -/
def _root_.ByteArray.fromHex (s : String) : Option ByteArray := do
  if s.length % 2 != 0 then none
  else
    let chars := s.toList
    let rec go (i : Nat) (acc : ByteArray) : Option ByteArray :=
      if i >= chars.length then some acc
      else do
        let hi := chars[i]!
        let lo := chars[i + 1]!
        let byte ← hexPairToUInt8 hi lo
        go (i + 2) (acc.push byte)
    go 0 ByteArray.empty

/-- Convert a hex byte (UInt8 ASCII value) to its numeric value (0-15).
    For byte-level parsing where input is raw ASCII bytes rather than Char.
    Returns `none` for invalid hex bytes. -/
def hexByteToNat (b : UInt8) : Option Nat :=
  if b >= 48 && b <= 57 then some (b - 48).toNat       -- '0'-'9'
  else if b >= 97 && b <= 102 then some (b - 87).toNat -- 'a'-'f'
  else if b >= 65 && b <= 70 then some (b - 55).toNat  -- 'A'-'F'
  else none

/-- Check if a byte (ASCII value) is a valid hex digit. -/
def isHexDigitByte (b : UInt8) : Bool :=
  (b >= 48 && b <= 57) || (b >= 97 && b <= 102) || (b >= 65 && b <= 70)

end Staple.Hex
