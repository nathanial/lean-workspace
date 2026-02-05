/-
  Tincture - HSL Color Space
  Hue, Saturation, Lightness - intuitive for color manipulation.
-/

import Tincture.Color

namespace Tincture

/-- HSL color space. Hue-Saturation-Lightness. -/
structure HSL where
  h : Float  -- Hue: 0.0 to 1.0 (0=red, 0.33=green, 0.67=blue)
  s : Float  -- Saturation: 0.0 (gray) to 1.0 (fully saturated)
  l : Float  -- Lightness: 0.0 (black) to 1.0 (white)
deriving Repr, BEq, Inhabited

namespace HSL

/-- Create HSL with normalized hue and clamped s/l. -/
def hsl (h s l : Float) : HSL :=
  let h' := h - h.floor  -- normalize to [0, 1)
  let s' := Color.clamp01 s
  let l' := Color.clamp01 l
  ⟨h', s', l'⟩

/-- Convert HSL to RGB Color. -/
def toColor (hsl : HSL) (alpha : Float := 1.0) : Color :=
  if hsl.s == 0.0 then
    -- Achromatic (gray)
    Color.rgba hsl.l hsl.l hsl.l alpha
  else
    let hueToRgb (p q t : Float) : Float :=
      let t' := if t < 0.0 then t + 1.0 else if t > 1.0 then t - 1.0 else t
      if t' < 1.0 / 6.0 then p + (q - p) * 6.0 * t'
      else if t' < 1.0 / 2.0 then q
      else if t' < 2.0 / 3.0 then p + (q - p) * (2.0 / 3.0 - t') * 6.0
      else p
    let q := if hsl.l < 0.5 then hsl.l * (1.0 + hsl.s) else hsl.l + hsl.s - hsl.l * hsl.s
    let p := 2.0 * hsl.l - q
    let r := hueToRgb p q (hsl.h + 1.0 / 3.0)
    let g := hueToRgb p q hsl.h
    let b := hueToRgb p q (hsl.h - 1.0 / 3.0)
    Color.rgba r g b alpha

/-- Convert RGB Color to HSL. -/
def fromColor (c : Color) : HSL :=
  let max := Float.max c.r (Float.max c.g c.b)
  let min := Float.min c.r (Float.min c.g c.b)
  let l := (max + min) / 2.0

  if max == min then
    -- Achromatic
    ⟨0.0, 0.0, l⟩
  else
    let d := max - min
    let s := if l > 0.5 then d / (2.0 - max - min) else d / (max + min)
    let h :=
      if max == c.r then
        let h' := (c.g - c.b) / d
        if c.g < c.b then h' + 6.0 else h'
      else if max == c.g then
        (c.b - c.r) / d + 2.0
      else
        (c.r - c.g) / d + 4.0
    ⟨h / 6.0, s, l⟩

/-- Rotate hue by given amount (0-1 = 0-360 degrees). -/
def rotateHue (hsl : HSL) (amount : Float) : HSL :=
  let h' := (hsl.h + amount) - (hsl.h + amount).floor
  ⟨h', hsl.s, hsl.l⟩

/-- Adjust saturation by relative amount (-1 to 1). -/
def adjustSaturation (hsl : HSL) (amount : Float) : HSL :=
  ⟨hsl.h, Color.clamp01 (hsl.s + amount), hsl.l⟩

/-- Adjust lightness by relative amount (-1 to 1). -/
def adjustLightness (hsl : HSL) (amount : Float) : HSL :=
  ⟨hsl.h, hsl.s, Color.clamp01 (hsl.l + amount)⟩

/-- Create complementary color (180 degree hue rotation). -/
def complementary (hsl : HSL) : HSL := rotateHue hsl 0.5

end HSL

namespace Color

/-- Convert Color to HSL. -/
def toHSL (c : Color) : HSL := HSL.fromColor c

/-- Create Color from HSL, with optional alpha. -/
def fromHSL (hsl : HSL) (alpha : Float := 1.0) : Color := HSL.toColor hsl alpha

/-- Create Color from HSL values directly. -/
def hsl (h s l : Float) : Color := HSL.toColor (HSL.hsl h s l) 1.0

/-- Create Color from HSLA values directly. -/
def hsla (h s l a : Float) : Color := HSL.toColor (HSL.hsl h s l) a

end Color

end Tincture
