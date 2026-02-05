/-
  Tincture - CMYK Color Space
  Subtractive color model used in printing.
  This is a basic conversion, not ICC profile-based.
-/

import Tincture.Color

namespace Tincture

/-- CMYK color space. Cyan-Magenta-Yellow-Key(Black). -/
structure CMYK where
  c : Float  -- Cyan: 0.0 to 1.0
  m : Float  -- Magenta: 0.0 to 1.0
  y : Float  -- Yellow: 0.0 to 1.0
  k : Float  -- Key (Black): 0.0 to 1.0
deriving Repr, BEq, Inhabited

namespace CMYK

/-- Create CMYK with clamped values. -/
def cmyk (c m y k : Float) : CMYK :=
  ⟨Color.clamp01 c, Color.clamp01 m, Color.clamp01 y, Color.clamp01 k⟩

/-- Convert RGB Color to CMYK. -/
def fromColor (col : Color) : CMYK :=
  let k := 1.0 - Float.max col.r (Float.max col.g col.b)
  if k >= 1.0 then
    -- Pure black
    ⟨0.0, 0.0, 0.0, 1.0⟩
  else
    let c := (1.0 - col.r - k) / (1.0 - k)
    let m := (1.0 - col.g - k) / (1.0 - k)
    let y := (1.0 - col.b - k) / (1.0 - k)
    ⟨c, m, y, k⟩

/-- Convert CMYK to RGB Color. -/
def toColor (cmyk : CMYK) (alpha : Float := 1.0) : Color :=
  let r := (1.0 - cmyk.c) * (1.0 - cmyk.k)
  let g := (1.0 - cmyk.m) * (1.0 - cmyk.k)
  let b := (1.0 - cmyk.y) * (1.0 - cmyk.k)
  Color.rgba r g b alpha

/-- Create CMYK from individual ink percentages (0-100%). -/
def fromPercent (c m y k : Float) : CMYK :=
  ⟨Color.clamp01 (c / 100.0),
   Color.clamp01 (m / 100.0),
   Color.clamp01 (y / 100.0),
   Color.clamp01 (k / 100.0)⟩

/-- Get ink coverage as percentage. -/
def toPercent (cmyk : CMYK) : Float × Float × Float × Float :=
  (cmyk.c * 100.0, cmyk.m * 100.0, cmyk.y * 100.0, cmyk.k * 100.0)

/-- Total ink coverage (sum of all inks). Used for print quality control.
    Typical maximum is 300-400% depending on paper/press. -/
def totalInk (cmyk : CMYK) : Float :=
  (cmyk.c + cmyk.m + cmyk.y + cmyk.k) * 100.0

end CMYK

namespace Color

/-- Convert Color to CMYK. -/
def toCMYK (c : Color) : CMYK := CMYK.fromColor c

/-- Create Color from CMYK, with optional alpha. -/
def fromCMYK (cmyk : CMYK) (alpha : Float := 1.0) : Color := CMYK.toColor cmyk alpha

end Color

end Tincture
