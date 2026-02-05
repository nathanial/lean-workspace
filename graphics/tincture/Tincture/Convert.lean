/-
  Tincture - Unified Color Space Conversion API
  Provides a single interface for converting between all color spaces.
-/

import Tincture.Color
import Tincture.Space.RGB
import Tincture.Space.HSL
import Tincture.Space.HSV
import Tincture.Space.HWB
import Tincture.Space.XYZ
import Tincture.Space.Lab
import Tincture.Space.LCH
import Tincture.Space.OkLab
import Tincture.Space.OkLCH
import Tincture.Space.CMYK

namespace Tincture

/-- Enumeration of supported color spaces. -/
inductive ColorSpace where
  | sRGB      -- Standard RGB (gamma-corrected)
  | linearRGB -- Linear RGB (no gamma)
  | hsl       -- Hue-Saturation-Lightness
  | hsv       -- Hue-Saturation-Value
  | hwb       -- Hue-Whiteness-Blackness
  | xyz       -- CIE XYZ
  | lab       -- CIE L*a*b*
  | lch       -- Cylindrical Lab
  | oklab     -- OkLab (modern perceptual)
  | oklch     -- Cylindrical OkLab
  | cmyk      -- Cyan-Magenta-Yellow-Key
deriving Repr, BEq, Inhabited

/-- Generic color value that can hold any color space representation. -/
inductive ColorValue where
  | sRGB (c : Color)
  | linearRGB (c : LinearRGB)
  | hsl (c : HSL)
  | hsv (c : HSV)
  | hwb (c : HWB)
  | xyz (c : XYZ)
  | lab (c : Lab)
  | lch (c : LCH)
  | oklab (c : OkLab)
  | oklch (c : OkLCH)
  | cmyk (c : CMYK)
deriving Repr

namespace ColorValue

/-- Get the color space of this value. -/
def space : ColorValue → ColorSpace
  | .sRGB _ => .sRGB
  | .linearRGB _ => .linearRGB
  | .hsl _ => .hsl
  | .hsv _ => .hsv
  | .hwb _ => .hwb
  | .xyz _ => .xyz
  | .lab _ => .lab
  | .lch _ => .lch
  | .oklab _ => .oklab
  | .oklch _ => .oklch
  | .cmyk _ => .cmyk

/-- Convert any ColorValue to sRGB Color. -/
def toColor : ColorValue → Color
  | .sRGB c => c
  | .linearRGB c => c.toColor
  | .hsl c => c.toColor
  | .hsv c => c.toColor
  | .hwb c => c.toColor
  | .xyz c => c.toColor
  | .lab c => c.toColor
  | .lch c => c.toColor
  | .oklab c => c.toColor
  | .oklch c => c.toColor
  | .cmyk c => c.toColor

/-- Convert sRGB Color to specified color space. -/
def fromColor (c : Color) (space : ColorSpace) : ColorValue :=
  match space with
  | .sRGB => .sRGB c
  | .linearRGB => .linearRGB (LinearRGB.fromColor c)
  | .hsl => .hsl (HSL.fromColor c)
  | .hsv => .hsv (HSV.fromColor c)
  | .hwb => .hwb (HWB.fromColor c)
  | .xyz => .xyz (XYZ.fromColor c)
  | .lab => .lab (Lab.fromColor c)
  | .lch => .lch (LCH.fromColor c)
  | .oklab => .oklab (OkLab.fromColor c)
  | .oklch => .oklch (OkLCH.fromColor c)
  | .cmyk => .cmyk (CMYK.fromColor c)

/-- Convert between any two color spaces. -/
def convert (cv : ColorValue) (targetSpace : ColorSpace) : ColorValue :=
  fromColor cv.toColor targetSpace

end ColorValue

namespace Color

/-- Convert to any color space. -/
def toSpace (c : Color) (space : ColorSpace) : ColorValue :=
  ColorValue.fromColor c space

end Color

end Tincture
