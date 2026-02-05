/-
  Tincture - Color Parsing
  Parse colors from various string formats.
-/

import Tincture.Color

namespace Tincture

namespace Color

-- TODO: Replace with Staple.Hex.hexCharToNat after staple release
/-- Parse a single hex digit to value 0-15. -/
private def hexDigitValue (c : Char) : Option UInt8 :=
  if c >= '0' && c <= '9' then some (c.toNat - '0'.toNat).toUInt8
  else if c >= 'a' && c <= 'f' then some (c.toNat - 'a'.toNat + 10).toUInt8
  else if c >= 'A' && c <= 'F' then some (c.toNat - 'A'.toNat + 10).toUInt8
  else none

/-- Parse two hex characters to a byte. -/
private def parseHexByte (s : String) (offset : Nat) : Option UInt8 := do
  if offset + 1 >= s.length then
    failure
  else
    let chars := s.toList
    let hi ← hexDigitValue chars[offset]!
    let lo ← hexDigitValue chars[offset + 1]!
    return hi * 16 + lo

/-- Parse a single hex character as a doubled byte (e.g., 'F' -> 0xFF). -/
private def parseHexNibble (s : String) (offset : Nat) : Option UInt8 := do
  if offset >= s.length then
    failure
  else
    let v ← hexDigitValue s.toList[offset]!
    return v * 16 + v

/-- Parse color from hex string.
    Supports: "#RGB", "#RGBA", "#RRGGBB", "#RRGGBBAA" (with or without #). -/
def fromHex (s : String) : Option Color := do
  let s := if s.startsWith "#" then s.drop 1 else s
  match s.length with
  | 3 => -- RGB short form
    let r ← parseHexNibble s 0
    let g ← parseHexNibble s 1
    let b ← parseHexNibble s 2
    return fromRgb8 r g b
  | 4 => -- RGBA short form
    let r ← parseHexNibble s 0
    let g ← parseHexNibble s 1
    let b ← parseHexNibble s 2
    let a ← parseHexNibble s 3
    return fromRgb8 r g b a
  | 6 => -- RRGGBB
    let r ← parseHexByte s 0
    let g ← parseHexByte s 2
    let b ← parseHexByte s 4
    return fromRgb8 r g b
  | 8 => -- RRGGBBAA
    let r ← parseHexByte s 0
    let g ← parseHexByte s 2
    let b ← parseHexByte s 4
    let a ← parseHexByte s 6
    return fromRgb8 r g b a
  | _ => failure

/-- Parse an integer from a string. -/
private def parseNat (s : String) : Option Nat := do
  let s := s.trim
  if s.isEmpty then failure
  else
    let chars := s.toList
    let rec go (cs : List Char) (acc : Nat) : Option Nat :=
      match cs with
      | [] => some acc
      | c :: rest =>
        if c >= '0' && c <= '9' then
          go rest (acc * 10 + (c.toNat - '0'.toNat))
        else
          none
    go chars 0

/-- Parse a float from a string (basic implementation). -/
private def parseFloat (s : String) : Option Float := do
  let s := s.trim
  if s.isEmpty then failure
  else
    -- Handle percentage
    if s.endsWith "%" then
      let n ← parseNat (s.dropRight 1)
      return n.toFloat / 100.0
    else
      -- Handle decimal
      let parts := s.splitOn "."
      match parts with
      | [whole] =>
        let n ← parseNat whole
        return n.toFloat
      | [whole, frac] =>
        let w ← parseNat whole
        let f ← parseNat frac
        let divisor := (10 : Float) ^ frac.length.toFloat
        return w.toFloat + f.toFloat / divisor
      | _ => failure

/-- Extract values from a function-style string like "rgb(255, 128, 0)". -/
private def extractValues (s : String) (prefixStr : String) : Option (Array String) := do
  if !s.startsWith prefixStr then failure
  else
    let rest := s.drop prefixStr.length
    let rest := rest.trim
    if !rest.startsWith "(" || !rest.endsWith ")" then failure
    else
      let inner := rest.drop 1 |>.dropRight 1
      -- Split by comma or space
      let values := if inner.any (· == ',') then
        inner.splitOn ","
      else
        inner.splitOn " " |>.filter (fun s => s.trim != "")
      return values.map String.trim |>.toArray

/-- Parse RGB from "rgb(r, g, b)" or "rgb(r g b)" format.
    Values can be 0-255 or percentages. -/
def fromRgbString (s : String) : Option Color := do
  let values ← extractValues s.toLower "rgb"
  if values.size != 3 then failure
  else
    let r ← parseFloat values[0]!
    let g ← parseFloat values[1]!
    let b ← parseFloat values[2]!
    -- Normalize: if > 1, assume 0-255 range
    let normalize (v : Float) : Float :=
      if v > 1.0 then clamp01 (v / 255.0) else clamp01 v
    return rgb (normalize r) (normalize g) (normalize b)

/-- Parse RGBA from "rgba(r, g, b, a)" format. -/
def fromRgbaString (s : String) : Option Color := do
  let values ← extractValues s.toLower "rgba"
  if values.size != 4 then failure
  else
    let r ← parseFloat values[0]!
    let g ← parseFloat values[1]!
    let b ← parseFloat values[2]!
    let a ← parseFloat values[3]!
    let normalize (v : Float) : Float :=
      if v > 1.0 then clamp01 (v / 255.0) else clamp01 v
    return rgba (normalize r) (normalize g) (normalize b) (clamp01 a)

/-- Try to parse color from any supported format. -/
def parse (s : String) : Option Color :=
  let s := s.trim
  -- Try hex first
  fromHex s <|> fromRgbaString s <|> fromRgbString s

end Color

end Tincture
