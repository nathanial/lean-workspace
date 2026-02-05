/-
  Tincture - CIE XYZ Color Space
  Device-independent reference space for converting between color spaces.
  Uses D65 standard illuminant (daylight).
-/

import Tincture.Color

namespace Tincture

/-- CIE XYZ color space. Device-independent reference space. -/
structure XYZ where
  x : Float  -- Mix of cone response curves
  y : Float  -- Luminance
  z : Float  -- Quasi-equal to blue
deriving Repr, BEq, Inhabited

namespace XYZ

-- D65 standard illuminant white point (daylight)
def d65_x : Float := 0.95047
def d65_y : Float := 1.0
def d65_z : Float := 1.08883

/-- Apply gamma correction for sRGB -> linear conversion. -/
private def gammaToLinear (c : Float) : Float :=
  if c <= 0.04045 then
    c / 12.92
  else
    ((c + 0.055) / 1.055) ^ 2.4

/-- Apply inverse gamma for linear -> sRGB conversion. -/
private def linearToGamma (c : Float) : Float :=
  if c <= 0.0031308 then
    c * 12.92
  else
    1.055 * (c ^ (1.0 / 2.4)) - 0.055

/-- Convert sRGB Color to XYZ. -/
def fromColor (c : Color) : XYZ :=
  -- Convert to linear RGB
  let r := gammaToLinear c.r
  let g := gammaToLinear c.g
  let b := gammaToLinear c.b
  -- sRGB to XYZ matrix (D65)
  let x := r * 0.4124564 + g * 0.3575761 + b * 0.1804375
  let y := r * 0.2126729 + g * 0.7151522 + b * 0.0721750
  let z := r * 0.0193339 + g * 0.1191920 + b * 0.9503041
  ⟨x, y, z⟩

/-- Convert XYZ to sRGB Color. -/
def toColor (xyz : XYZ) (alpha : Float := 1.0) : Color :=
  -- XYZ to linear RGB matrix (D65)
  let r := xyz.x *  3.2404542 + xyz.y * (-1.5371385) + xyz.z * (-0.4985314)
  let g := xyz.x * (-0.9692660) + xyz.y *  1.8760108  + xyz.z *  0.0415560
  let b := xyz.x *  0.0556434 + xyz.y * (-0.2040259) + xyz.z *  1.0572252
  -- Convert to sRGB with gamma
  Color.rgba (linearToGamma r) (linearToGamma g) (linearToGamma b) alpha

end XYZ

namespace Color

/-- Convert Color to XYZ. -/
def toXYZ (c : Color) : XYZ := XYZ.fromColor c

/-- Create Color from XYZ, preserving original alpha. -/
def fromXYZ (xyz : XYZ) (alpha : Float := 1.0) : Color := XYZ.toColor xyz alpha

end Color

end Tincture
