/-
  Tincture - RGB Color Space Utilities
  Linear RGB and gamma correction utilities.
-/

import Tincture.Color

namespace Tincture

/-- Linear RGB color (no gamma correction). Used for accurate color math. -/
structure LinearRGB where
  r : Float
  g : Float
  b : Float
deriving Repr, BEq, Inhabited

namespace LinearRGB

/-- Apply gamma correction for sRGB -> linear conversion. -/
def gammaToLinear (c : Float) : Float :=
  if c <= 0.04045 then
    c / 12.92
  else
    ((c + 0.055) / 1.055) ^ 2.4

/-- Apply inverse gamma for linear -> sRGB conversion. -/
def linearToGamma (c : Float) : Float :=
  if c <= 0.0031308 then
    c * 12.92
  else
    1.055 * (c ^ (1.0 / 2.4)) - 0.055

/-- Convert sRGB Color to linear RGB. -/
def fromColor (c : Color) : LinearRGB :=
  ⟨gammaToLinear c.r, gammaToLinear c.g, gammaToLinear c.b⟩

/-- Convert linear RGB to sRGB Color. -/
def toColor (rgb : LinearRGB) (alpha : Float := 1.0) : Color :=
  Color.rgba (linearToGamma rgb.r) (linearToGamma rgb.g) (linearToGamma rgb.b) alpha

/-- Linear interpolation in linear RGB space (physically accurate). -/
def lerp (rgb1 rgb2 : LinearRGB) (t : Float) : LinearRGB :=
  let t' := Color.clamp01 t
  ⟨rgb1.r + (rgb2.r - rgb1.r) * t',
   rgb1.g + (rgb2.g - rgb1.g) * t',
   rgb1.b + (rgb2.b - rgb1.b) * t'⟩

/-- Add two linear RGB colors (for light mixing). -/
def add (rgb1 rgb2 : LinearRGB) : LinearRGB :=
  ⟨rgb1.r + rgb2.r, rgb1.g + rgb2.g, rgb1.b + rgb2.b⟩

/-- Multiply two linear RGB colors (for filtering/absorption). -/
def mul (rgb1 rgb2 : LinearRGB) : LinearRGB :=
  ⟨rgb1.r * rgb2.r, rgb1.g * rgb2.g, rgb1.b * rgb2.b⟩

/-- Scale linear RGB by a factor. -/
def scale (rgb : LinearRGB) (factor : Float) : LinearRGB :=
  ⟨rgb.r * factor, rgb.g * factor, rgb.b * factor⟩

end LinearRGB

namespace Color

/-- Convert Color to linear RGB. -/
def toLinearRGB (c : Color) : LinearRGB := LinearRGB.fromColor c

/-- Create Color from linear RGB, with optional alpha. -/
def fromLinearRGB (rgb : LinearRGB) (alpha : Float := 1.0) : Color := LinearRGB.toColor rgb alpha

/-- Physically accurate linear interpolation (in linear RGB space). -/
def lerpLinear (c1 c2 : Color) (t : Float) : Color :=
  let rgb1 := LinearRGB.fromColor c1
  let rgb2 := LinearRGB.fromColor c2
  let result := LinearRGB.lerp rgb1 rgb2 t
  let c := LinearRGB.toColor result
  let t' := clamp01 t
  ⟨c.r, c.g, c.b, c1.a + (c2.a - c1.a) * t'⟩

end Color

end Tincture
