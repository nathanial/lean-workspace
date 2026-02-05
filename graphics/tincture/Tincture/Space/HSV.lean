/-
  Tincture - HSV Color Space
  Hue, Saturation, Value (Brightness).
-/

import Tincture.Color

namespace Tincture

/-- HSV color space. Hue-Saturation-Value. -/
structure HSV where
  h : Float  -- Hue: 0.0 to 1.0 (0=red, 0.33=green, 0.67=blue)
  s : Float  -- Saturation: 0.0 (gray) to 1.0 (fully saturated)
  v : Float  -- Value/Brightness: 0.0 (black) to 1.0 (full brightness)
deriving Repr, BEq, Inhabited

namespace HSV

/-- Create HSV with normalized hue and clamped s/v. -/
def hsv (h s v : Float) : HSV :=
  let h' := h - h.floor  -- normalize to [0, 1)
  let s' := Color.clamp01 s
  let v' := Color.clamp01 v
  ⟨h', s', v'⟩

/-- Convert HSV to RGB Color. -/
def toColor (hsv : HSV) (alpha : Float := 1.0) : Color :=
  if hsv.s == 0.0 then
    Color.rgba hsv.v hsv.v hsv.v alpha
  else
    let h' := hsv.h - hsv.h.floor  -- normalize to [0, 1)
    let sector := (h' * 6.0).floor
    let f := h' * 6.0 - sector
    let p := hsv.v * (1.0 - hsv.s)
    let q := hsv.v * (1.0 - hsv.s * f)
    let t := hsv.v * (1.0 - hsv.s * (1.0 - f))
    let (r, g, b) := match sector.toUInt8 % 6 with
      | 0 => (hsv.v, t, p)
      | 1 => (q, hsv.v, p)
      | 2 => (p, hsv.v, t)
      | 3 => (p, q, hsv.v)
      | 4 => (t, p, hsv.v)
      | _ => (hsv.v, p, q)
    Color.rgba r g b alpha

/-- Convert RGB Color to HSV. -/
def fromColor (c : Color) : HSV :=
  let max := Float.max c.r (Float.max c.g c.b)
  let min := Float.min c.r (Float.min c.g c.b)
  let d := max - min

  let v := max
  let s := if max == 0.0 then 0.0 else d / max

  if max == min then
    ⟨0.0, s, v⟩  -- achromatic
  else
    let h :=
      if max == c.r then
        let h' := (c.g - c.b) / d
        if c.g < c.b then h' + 6.0 else h'
      else if max == c.g then
        (c.b - c.r) / d + 2.0
      else
        (c.r - c.g) / d + 4.0
    ⟨h / 6.0, s, v⟩

/-- Rotate hue by given amount (0-1 = 0-360 degrees). -/
def rotateHue (hsv : HSV) (amount : Float) : HSV :=
  let h' := (hsv.h + amount) - (hsv.h + amount).floor
  ⟨h', hsv.s, hsv.v⟩

/-- Adjust saturation by relative amount (-1 to 1). -/
def adjustSaturation (hsv : HSV) (amount : Float) : HSV :=
  ⟨hsv.h, Color.clamp01 (hsv.s + amount), hsv.v⟩

/-- Adjust value by relative amount (-1 to 1). -/
def adjustValue (hsv : HSV) (amount : Float) : HSV :=
  ⟨hsv.h, hsv.s, Color.clamp01 (hsv.v + amount)⟩

end HSV

namespace Color

/-- Convert Color to HSV. -/
def toHSV (c : Color) : HSV := HSV.fromColor c

/-- Create Color from HSV, with optional alpha. -/
def fromHSV (hsv : HSV) (alpha : Float := 1.0) : Color := HSV.toColor hsv alpha

/-- Create color from HSV values. H in [0,1], S and V in [0,1]. -/
def hsv (h s v : Float) : Color := HSV.toColor (HSV.hsv h s v) 1.0

/-- Create color from HSVA values. H in [0,1], S, V, A in [0,1]. -/
def hsva (h s v a : Float) : Color := HSV.toColor (HSV.hsv h s v) a

end Color

end Tincture
