/-
  Tincture - LCH Color Space
  Cylindrical representation of CIE L*a*b*.
  Better for programmatic color manipulation.
-/

import Tincture.Space.Lab

namespace Tincture

/-- LCH color space. Lightness-Chroma-Hue (cylindrical Lab). -/
structure LCH where
  l : Float  -- Lightness: 0 (black) to 100 (white)
  c : Float  -- Chroma: 0 (gray) to ~130+ (saturated)
  h : Float  -- Hue: 0.0 to 1.0 (normalized, 0=red, ~0.33=green, ~0.67=blue)
deriving Repr, BEq, Inhabited

namespace LCH

/-- Create LCH with clamped lightness. -/
def lch (l c h : Float) : LCH :=
  let l' := if l < 0.0 then 0.0 else if l > 100.0 then 100.0 else l
  let c' := if c < 0.0 then 0.0 else c
  let h' := h - h.floor
  ⟨l', c', h'⟩

/-- Convert Lab to LCH. -/
def fromLab (lab : Lab) : LCH :=
  let c := Float.sqrt (lab.a * lab.a + lab.b * lab.b)
  let h := if c < 0.0001 then 0.0 else
    let angle := Float.atan2 lab.b lab.a
    let normalized := angle / (2.0 * Float.pi)
    if normalized < 0.0 then normalized + 1.0 else normalized
  ⟨lab.l, c, h⟩

/-- Convert LCH to Lab. -/
def toLab (lch : LCH) : Lab :=
  let angle := lch.h * 2.0 * Float.pi
  let a := lch.c * Float.cos angle
  let b := lch.c * Float.sin angle
  ⟨lch.l, a, b⟩

/-- Convert LCH to sRGB Color. -/
def toColor (lch : LCH) (alpha : Float := 1.0) : Color :=
  Lab.toColor (toLab lch) alpha

/-- Convert sRGB Color to LCH. -/
def fromColor (c : Color) : LCH :=
  fromLab (Lab.fromColor c)

/-- Rotate hue by given amount. -/
def rotateHue (lch : LCH) (amount : Float) : LCH :=
  let h' := (lch.h + amount) - (lch.h + amount).floor
  ⟨lch.l, lch.c, h'⟩

/-- Adjust lightness by relative amount. -/
def adjustLightness (lch : LCH) (amount : Float) : LCH :=
  let l' := lch.l + amount
  ⟨if l' < 0.0 then 0.0 else if l' > 100.0 then 100.0 else l', lch.c, lch.h⟩

/-- Adjust chroma by relative amount. -/
def adjustChroma (lch : LCH) (amount : Float) : LCH :=
  let c' := lch.c + amount
  ⟨lch.l, if c' < 0.0 then 0.0 else c', lch.h⟩

/-- Create complementary color (180 degree hue rotation). -/
def complementary (lch : LCH) : LCH := rotateHue lch 0.5

end LCH

namespace Color

/-- Convert Color to LCH. -/
def toLCH (c : Color) : LCH := LCH.fromColor c

/-- Create Color from LCH, with optional alpha. -/
def fromLCH (lch : LCH) (alpha : Float := 1.0) : Color := LCH.toColor lch alpha

end Color

end Tincture
