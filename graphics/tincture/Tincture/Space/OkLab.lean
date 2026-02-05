/-
  Tincture - OkLab Color Space
  Modern perceptually uniform color space by Björn Ottosson.
  Default for CSS Color Level 4 interpolation.
-/

import Tincture.Color

namespace Tincture

/-- OkLab color space. Modern perceptually uniform space. -/
structure OkLab where
  l : Float  -- Lightness: 0 (black) to 1 (white)
  a : Float  -- Green (-) to Red (+)
  b : Float  -- Blue (-) to Yellow (+)
deriving Repr, BEq, Inhabited

namespace OkLab

/-- Convert linear sRGB to OkLab. -/
def fromLinearRgb (r g b : Float) : OkLab :=
  -- Linear RGB to LMS
  let l := 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
  let m := 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
  let s := 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

  -- Cube root
  let l' := if l >= 0.0 then l ^ (1.0/3.0) else -((-l) ^ (1.0/3.0))
  let m' := if m >= 0.0 then m ^ (1.0/3.0) else -((-m) ^ (1.0/3.0))
  let s' := if s >= 0.0 then s ^ (1.0/3.0) else -((-s) ^ (1.0/3.0))

  -- LMS to OkLab
  let L := 0.2104542553 * l' + 0.7936177850 * m' - 0.0040720468 * s'
  let a := 1.9779984951 * l' - 2.4285922050 * m' + 0.4505937099 * s'
  let bb := 0.0259040371 * l' + 0.7827717662 * m' - 0.8086757660 * s'
  ⟨L, a, bb⟩

/-- Convert OkLab to linear sRGB. -/
def toLinearRgb (lab : OkLab) : Float × Float × Float :=
  -- OkLab to LMS (cube root)
  let l' := lab.l + 0.3963377774 * lab.a + 0.2158037573 * lab.b
  let m' := lab.l - 0.1055613458 * lab.a - 0.0638541728 * lab.b
  let s' := lab.l - 0.0894841775 * lab.a - 1.2914855480 * lab.b

  -- Cube
  let l := l' * l' * l'
  let m := m' * m' * m'
  let s := s' * s' * s'

  -- LMS to linear RGB
  let r :=  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
  let g := -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
  let b := -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
  (r, g, b)

/-- Apply gamma correction for linear -> sRGB conversion. -/
private def linearToGamma (c : Float) : Float :=
  if c <= 0.0031308 then
    c * 12.92
  else
    1.055 * (c ^ (1.0 / 2.4)) - 0.055

/-- Apply gamma correction for sRGB -> linear conversion. -/
private def gammaToLinear (c : Float) : Float :=
  if c <= 0.04045 then
    c / 12.92
  else
    ((c + 0.055) / 1.055) ^ 2.4

/-- Convert sRGB Color to OkLab. -/
def fromColor (c : Color) : OkLab :=
  let r := gammaToLinear c.r
  let g := gammaToLinear c.g
  let b := gammaToLinear c.b
  fromLinearRgb r g b

/-- Convert OkLab to sRGB Color. -/
def toColor (lab : OkLab) (alpha : Float := 1.0) : Color :=
  let (r, g, b) := toLinearRgb lab
  Color.rgba (linearToGamma r) (linearToGamma g) (linearToGamma b) alpha

/-- Create OkLab color. -/
def oklab (l a b : Float) : OkLab :=
  ⟨Color.clamp01 l, a, b⟩

/-- Linear interpolation in OkLab space (perceptually smooth). -/
def lerp (lab1 lab2 : OkLab) (t : Float) : OkLab :=
  let t' := Color.clamp01 t
  ⟨lab1.l + (lab2.l - lab1.l) * t',
   lab1.a + (lab2.a - lab1.a) * t',
   lab1.b + (lab2.b - lab1.b) * t'⟩

end OkLab

namespace Color

/-- Convert Color to OkLab. -/
def toOkLab (c : Color) : OkLab := OkLab.fromColor c

/-- Create Color from OkLab, with optional alpha. -/
def fromOkLab (lab : OkLab) (alpha : Float := 1.0) : Color := OkLab.toColor lab alpha

/-- Perceptually smooth linear interpolation using OkLab. -/
def lerpOkLab (c1 c2 : Color) (t : Float) : Color :=
  let lab1 := OkLab.fromColor c1
  let lab2 := OkLab.fromColor c2
  let result := OkLab.lerp lab1 lab2 t
  let c := OkLab.toColor result
  -- Preserve interpolated alpha
  let t' := Color.clamp01 t
  ⟨c.r, c.g, c.b, c1.a + (c2.a - c1.a) * t'⟩

end Color

end Tincture
