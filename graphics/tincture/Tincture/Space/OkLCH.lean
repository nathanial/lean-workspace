/-
  Tincture - OkLCH Color Space
  Cylindrical representation of OkLab.
  Excellent for color manipulation with perceptual uniformity.
-/

import Tincture.Space.OkLab

namespace Tincture

/-- OkLCH color space. Lightness-Chroma-Hue (cylindrical OkLab). -/
structure OkLCH where
  l : Float  -- Lightness: 0 (black) to 1 (white)
  c : Float  -- Chroma: 0 (gray) to ~0.4 (saturated)
  h : Float  -- Hue: 0.0 to 1.0 (normalized, 0=red, ~0.33=green, ~0.67=blue)
deriving Repr, BEq, Inhabited

namespace OkLCH

/-- Create OkLCH with clamped values. -/
def oklch (l c h : Float) : OkLCH :=
  let l' := Color.clamp01 l
  let c' := if c < 0.0 then 0.0 else c
  let h' := h - h.floor
  ⟨l', c', h'⟩

/-- Convert OkLab to OkLCH. -/
def fromOkLab (lab : OkLab) : OkLCH :=
  let c := Float.sqrt (lab.a * lab.a + lab.b * lab.b)
  let h := if c < 0.0001 then 0.0 else
    let angle := Float.atan2 lab.b lab.a
    let normalized := angle / (2.0 * Float.pi)
    if normalized < 0.0 then normalized + 1.0 else normalized
  ⟨lab.l, c, h⟩

/-- Convert OkLCH to OkLab. -/
def toOkLab (lch : OkLCH) : OkLab :=
  let angle := lch.h * 2.0 * Float.pi
  let a := lch.c * Float.cos angle
  let b := lch.c * Float.sin angle
  ⟨lch.l, a, b⟩

/-- Convert OkLCH to sRGB Color. -/
def toColor (lch : OkLCH) (alpha : Float := 1.0) : Color :=
  OkLab.toColor (toOkLab lch) alpha

/-- Convert sRGB Color to OkLCH. -/
def fromColor (c : Color) : OkLCH :=
  fromOkLab (OkLab.fromColor c)

/-- Rotate hue by given amount. -/
def rotateHue (lch : OkLCH) (amount : Float) : OkLCH :=
  let h' := (lch.h + amount) - (lch.h + amount).floor
  ⟨lch.l, lch.c, h'⟩

/-- Adjust lightness by relative amount. -/
def adjustLightness (lch : OkLCH) (amount : Float) : OkLCH :=
  ⟨Color.clamp01 (lch.l + amount), lch.c, lch.h⟩

/-- Adjust chroma by relative amount. -/
def adjustChroma (lch : OkLCH) (amount : Float) : OkLCH :=
  let c' := lch.c + amount
  ⟨lch.l, if c' < 0.0 then 0.0 else c', lch.h⟩

/-- Create complementary color (180 degree hue rotation). -/
def complementary (lch : OkLCH) : OkLCH := rotateHue lch 0.5

/-- Linear interpolation in OkLCH space.
    Uses shorter hue path by default. -/
def lerp (lch1 lch2 : OkLCH) (t : Float) : OkLCH :=
  let t' := Color.clamp01 t
  let l := lch1.l + (lch2.l - lch1.l) * t'
  let c := lch1.c + (lch2.c - lch1.c) * t'
  -- Use shorter hue path
  let hDiff := lch2.h - lch1.h
  let hDiff' := if hDiff > 0.5 then hDiff - 1.0
                else if hDiff < -0.5 then hDiff + 1.0
                else hDiff
  let h := lch1.h + hDiff' * t'
  let h' := if h < 0.0 then h + 1.0 else if h >= 1.0 then h - 1.0 else h
  ⟨l, c, h'⟩

end OkLCH

namespace Color

/-- Convert Color to OkLCH. -/
def toOkLCH (c : Color) : OkLCH := OkLCH.fromColor c

/-- Create Color from OkLCH, with optional alpha. -/
def fromOkLCH (lch : OkLCH) (alpha : Float := 1.0) : Color := OkLCH.toColor lch alpha

/-- Perceptually smooth hue-preserving interpolation using OkLCH. -/
def lerpOkLCH (c1 c2 : Color) (t : Float) : Color :=
  let lch1 := OkLCH.fromColor c1
  let lch2 := OkLCH.fromColor c2
  let result := OkLCH.lerp lch1 lch2 t
  let c := OkLCH.toColor result
  let t' := Color.clamp01 t
  ⟨c.r, c.g, c.b, c1.a + (c2.a - c1.a) * t'⟩

end Color

end Tincture
