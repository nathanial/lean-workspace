/-
  Tincture - HWB Color Space
  Hue, Whiteness, Blackness - intuitive for "tinting" colors.
-/

import Tincture.Space.HSV

namespace Tincture

/-- HWB color space. Hue-Whiteness-Blackness.
    Think of it as mixing pure hue with white and black paint. -/
structure HWB where
  h : Float  -- Hue: 0.0 to 1.0 (0=red, 0.33=green, 0.67=blue)
  w : Float  -- Whiteness: 0.0 to 1.0 (amount of white mixed in)
  b : Float  -- Blackness: 0.0 to 1.0 (amount of black mixed in)
deriving Repr, BEq, Inhabited

namespace HWB

/-- Create HWB with normalized hue and clamped w/b.
    If w + b > 1, they are normalized proportionally. -/
def hwb (h w b : Float) : HWB :=
  let h' := h - h.floor
  let w' := Color.clamp01 w
  let b' := Color.clamp01 b
  -- If w + b > 1, normalize them
  if w' + b' > 1.0 then
    let sum := w' + b'
    ⟨h', w' / sum, b' / sum⟩
  else
    ⟨h', w', b'⟩

/-- Convert HWB to RGB Color. -/
def toColor (hwb : HWB) (alpha : Float := 1.0) : Color :=
  -- HWB to RGB via HSV (saturation and value derived from w and b)
  let w := hwb.w
  let b := hwb.b
  -- Handle case where w + b >= 1 (gray)
  if w + b >= 1.0 then
    let gray := w / (w + b)
    Color.rgba gray gray gray alpha
  else
    -- Start with pure hue (HSV with s=1, v=1)
    let pureColor := HSV.toColor ⟨hwb.h, 1.0, 1.0⟩ 1.0
    -- Mix with white and black
    let factor := 1.0 - w - b
    let r := pureColor.r * factor + w
    let g := pureColor.g * factor + w
    let bl := pureColor.b * factor + w
    Color.rgba r g bl alpha

/-- Convert RGB Color to HWB. -/
def fromColor (c : Color) : HWB :=
  let hsv := HSV.fromColor c
  let max := Float.max c.r (Float.max c.g c.b)
  let min := Float.min c.r (Float.min c.g c.b)
  ⟨hsv.h, min, 1.0 - max⟩

/-- Rotate hue by given amount. -/
def rotateHue (hwb : HWB) (amount : Float) : HWB :=
  let h' := (hwb.h + amount) - (hwb.h + amount).floor
  ⟨h', hwb.w, hwb.b⟩

/-- Add whiteness (like mixing in white paint). -/
def addWhite (h : HWB) (amount : Float) : HWB :=
  hwb h.h (h.w + amount) h.b

/-- Add blackness (like mixing in black paint). -/
def addBlack (h : HWB) (amount : Float) : HWB :=
  hwb h.h h.w (h.b + amount)

end HWB

namespace Color

/-- Convert Color to HWB. -/
def toHWB (c : Color) : HWB := HWB.fromColor c

/-- Create Color from HWB, with optional alpha. -/
def fromHWB (hwb : HWB) (alpha : Float := 1.0) : Color := HWB.toColor hwb alpha

/-- Create Color from HWB values directly. -/
def hwb (h w b : Float) : Color := HWB.toColor (HWB.hwb h w b) 1.0

end Color

end Tincture
