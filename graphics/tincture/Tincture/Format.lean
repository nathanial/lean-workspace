/-
  Tincture - Color Formatting
  Convert colors to various string formats.
-/

import Tincture.Color
import Tincture.Space.HSL

namespace Tincture

namespace Color

/-- Hex digit characters for conversion. -/
private def hexDigits : List Char := "0123456789abcdef".toList

/-- Convert a byte to two hex characters. -/
private def toHexByte (v : UInt8) : String :=
  let hi := (v / 16).toNat
  let lo := (v % 16).toNat
  String.singleton hexDigits[hi]! ++ String.singleton hexDigits[lo]!

/-- Convert color to hex string.
    format: "#RRGGBB" or "#RRGGBBAA" if includeAlpha is true. -/
def toHex (c : Color) (includeAlpha : Bool := false) : String :=
  let (r, g, b, a) := c.toRgb8
  let rgb := "#" ++ toHexByte r ++ toHexByte g ++ toHexByte b
  if includeAlpha then rgb ++ toHexByte a else rgb

/-- Convert color to short hex if possible (#RGB or #RRGGBB). -/
def toHexShort (c : Color) (includeAlpha : Bool := false) : String :=
  let (r, g, b, a) := c.toRgb8
  -- Check if we can use short form (each byte is like 0xNN where both nibbles are same)
  let canShorten (v : UInt8) : Bool := (v / 16) == (v % 16)
  if canShorten r && canShorten g && canShorten b && (!includeAlpha || canShorten a) then
    let toSingle (v : UInt8) : String :=
      String.singleton hexDigits[(v / 16).toNat]!
    let short := "#" ++ toSingle r ++ toSingle g ++ toSingle b
    if includeAlpha then short ++ toSingle a else short
  else
    toHex c includeAlpha

/-- Round float to specified decimal places. -/
private def roundTo (v : Float) (places : Nat) : Float :=
  let factor := (10 : Float) ^ places.toFloat
  (v * factor).round / factor

/-- Format float for output (remove trailing zeros). -/
private def formatFloat (v : Float) (places : Nat := 2) : String :=
  let rounded := roundTo v places
  let s := toString rounded
  -- Remove unnecessary trailing zeros
  if s.any (· == '.') then
    let s := s.dropRightWhile (· == '0')
    if s.endsWith "." then s.dropRight 1 else s
  else s

/-- Format as percentage. -/
private def formatPercent (v : Float) (places : Nat := 0) : String :=
  formatFloat (v * 100.0) places ++ "%"

/-- Convert color to RGB string "rgb(r, g, b)" with 0-255 values. -/
def toRgbString (c : Color) : String :=
  let (r, g, b, _) := c.toRgb8
  s!"rgb({r}, {g}, {b})"

/-- Convert color to RGBA string "rgba(r, g, b, a)" with 0-255 values and 0-1 alpha. -/
def toRgbaString (c : Color) : String :=
  let (r, g, b, _) := c.toRgb8
  s!"rgba({r}, {g}, {b}, {formatFloat c.a 3})"

/-- Convert color to RGB string with percentages. -/
def toRgbPercentString (c : Color) : String :=
  s!"rgb({formatPercent c.r}, {formatPercent c.g}, {formatPercent c.b})"

/-- Convert color to HSL string "hsl(h, s%, l%)". -/
def toHslString (c : Color) : String :=
  let hsl := HSL.fromColor c
  let h := (hsl.h * 360.0).round.toUInt64
  s!"hsl({h}, {formatPercent hsl.s}, {formatPercent hsl.l})"

/-- Convert color to HSLA string "hsla(h, s%, l%, a)". -/
def toHslaString (c : Color) : String :=
  let hsl := HSL.fromColor c
  let h := (hsl.h * 360.0).round.toUInt64
  s!"hsla({h}, {formatPercent hsl.s}, {formatPercent hsl.l}, {formatFloat c.a 3})"

/-- Convert to CSS-compatible string.
    Uses rgba if alpha < 1, otherwise rgb. -/
def toCssString (c : Color) : String :=
  if c.a < 1.0 then toRgbaString c else toRgbString c

/-- Convert to CSS modern syntax with space-separated values.
    e.g., "rgb(255 128 0)" or "rgb(255 128 0 / 50%)" -/
def toCssModern (c : Color) : String :=
  let (r, g, b, _) := c.toRgb8
  if c.a < 1.0 then
    s!"rgb({r} {g} {b} / {formatPercent c.a})"
  else
    s!"rgb({r} {g} {b})"

/-- Convert to debug string with all components. -/
def toDebugString (c : Color) : String :=
  s!"Color(r={formatFloat c.r 4}, g={formatFloat c.g 4}, b={formatFloat c.b 4}, a={formatFloat c.a 4})"

/-- Instance for string conversion. -/
instance : ToString Color where
  toString c := toHex c false

end Color

end Tincture
