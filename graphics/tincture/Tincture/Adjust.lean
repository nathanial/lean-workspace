/-
  Tincture - Color Adjustment Operations
  Lighten, darken, saturate, and other color transformations.
-/

import Tincture.Space.HSL
import Tincture.Space.OkLCH

namespace Tincture

namespace Color

/-- Lighten a color by the given amount (0-1).
    Uses HSL lightness for intuitive results. -/
def lighten (c : Color) (amount : Float) : Color :=
  let hsl := HSL.fromColor c
  let l' := clamp01 (hsl.l + amount)
  HSL.toColor ⟨hsl.h, hsl.s, l'⟩ c.a

/-- Darken a color by the given amount (0-1). -/
def darken (c : Color) (amount : Float) : Color :=
  lighten c (-amount)

/-- Increase saturation by the given amount (0-1). -/
def saturate (c : Color) (amount : Float) : Color :=
  let hsl := HSL.fromColor c
  let s' := clamp01 (hsl.s + amount)
  HSL.toColor ⟨hsl.h, s', hsl.l⟩ c.a

/-- Decrease saturation by the given amount (0-1). -/
def desaturate (c : Color) (amount : Float) : Color :=
  saturate c (-amount)

/-- Rotate hue by the given amount (0-1 = 0-360 degrees). -/
def rotateHue (c : Color) (amount : Float) : Color :=
  let hsl := HSL.fromColor c
  let h' := (hsl.h + amount) - (hsl.h + amount).floor
  HSL.toColor ⟨h', hsl.s, hsl.l⟩ c.a

/-- Rotate hue by degrees (0-360). -/
def rotateHueDeg (c : Color) (degrees : Float) : Color :=
  rotateHue c (degrees / 360.0)

/-- Invert the color (RGB complement). -/
def invert (c : Color) : Color :=
  ⟨1.0 - c.r, 1.0 - c.g, 1.0 - c.b, c.a⟩

/-- Convert to grayscale using luminance weights. -/
def grayscale (c : Color) : Color :=
  -- ITU-R BT.709 luminance coefficients
  let lum := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
  ⟨lum, lum, lum, c.a⟩

/-- Apply sepia tone filter. -/
def sepia (c : Color) : Color :=
  let r := clamp01 (c.r * 0.393 + c.g * 0.769 + c.b * 0.189)
  let g := clamp01 (c.r * 0.349 + c.g * 0.686 + c.b * 0.168)
  let b := clamp01 (c.r * 0.272 + c.g * 0.534 + c.b * 0.131)
  ⟨r, g, b, c.a⟩

/-- Adjust brightness by a factor (1.0 = no change, 2.0 = twice as bright). -/
def brightness (c : Color) (factor : Float) : Color :=
  ⟨clamp01 (c.r * factor),
   clamp01 (c.g * factor),
   clamp01 (c.b * factor),
   c.a⟩

/-- Adjust contrast by a factor (1.0 = no change). -/
def contrast (c : Color) (factor : Float) : Color :=
  let adjust (v : Float) : Float :=
    clamp01 ((v - 0.5) * factor + 0.5)
  ⟨adjust c.r, adjust c.g, adjust c.b, c.a⟩

/-- Fade color by reducing alpha. -/
def fade (c : Color) (amount : Float) : Color :=
  ⟨c.r, c.g, c.b, clamp01 (c.a - amount)⟩

/-- Increase alpha (opacity). -/
def opacify (c : Color) (amount : Float) : Color :=
  fade c (-amount)

/-- Tint towards white by the given amount (0-1). -/
def tint (c : Color) (amount : Float) : Color :=
  lerp c white amount

/-- Shade towards black by the given amount (0-1). -/
def shade (c : Color) (amount : Float) : Color :=
  lerp c black amount

/-- Tone towards gray by the given amount (0-1). -/
def tone (c : Color) (amount : Float) : Color :=
  lerp c (gray 0.5) amount

/-- Adjust lightness in OkLCH space (perceptually uniform). -/
def adjustLightnessOk (c : Color) (amount : Float) : Color :=
  let lch := OkLCH.fromColor c
  let l' := clamp01 (lch.l + amount)
  OkLCH.toColor ⟨l', lch.c, lch.h⟩ c.a

/-- Adjust chroma (colorfulness) in OkLCH space. -/
def adjustChroma (c : Color) (amount : Float) : Color :=
  let lch := OkLCH.fromColor c
  let c' := if lch.c + amount < 0.0 then 0.0 else lch.c + amount
  OkLCH.toColor ⟨lch.l, c', lch.h⟩ c.a

/-- Make color warmer (shift towards red/yellow). -/
def warm (c : Color) (amount : Float) : Color :=
  let r := clamp01 (c.r + amount)
  let b := clamp01 (c.b - amount)
  ⟨r, c.g, b, c.a⟩

/-- Make color cooler (shift towards blue). -/
def cool (c : Color) (amount : Float) : Color :=
  warm c (-amount)

/-- Negate all channels (including computing complement for color channels). -/
def negate (c : Color) : Color :=
  ⟨1.0 - c.r, 1.0 - c.g, 1.0 - c.b, c.a⟩

end Color

end Tincture
