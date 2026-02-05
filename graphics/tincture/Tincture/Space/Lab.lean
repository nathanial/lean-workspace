/-
  Tincture - CIE L*a*b* Color Space
  Perceptually uniform color space designed to match human vision.
-/

import Tincture.Space.XYZ

namespace Tincture

/-- CIE L*a*b* color space. Perceptually uniform. -/
structure Lab where
  l : Float  -- Lightness: 0 (black) to 100 (white)
  a : Float  -- Green (-) to Red (+), roughly -128 to 127
  b : Float  -- Blue (-) to Yellow (+), roughly -128 to 127
deriving Repr, BEq, Inhabited

namespace Lab

-- Constants for Lab conversion
private def epsilon : Float := 0.008856  -- (6/29)^3
private def kappa : Float := 903.3       -- (29/3)^3

/-- Forward transformation for Lab conversion. -/
private def f (t : Float) : Float :=
  if t > epsilon then
    t ^ (1.0 / 3.0)
  else
    (kappa * t + 16.0) / 116.0

/-- Inverse transformation for Lab conversion. -/
private def fInv (t : Float) : Float :=
  let t3 := t * t * t
  if t3 > epsilon then
    t3
  else
    (116.0 * t - 16.0) / kappa

/-- Convert XYZ to Lab. -/
def fromXYZ (xyz : XYZ) : Lab :=
  let xn := xyz.x / XYZ.d65_x
  let yn := xyz.y / XYZ.d65_y
  let zn := xyz.z / XYZ.d65_z
  let fx := f xn
  let fy := f yn
  let fz := f zn
  let l := 116.0 * fy - 16.0
  let a := 500.0 * (fx - fy)
  let b := 200.0 * (fy - fz)
  ⟨l, a, b⟩

/-- Convert Lab to XYZ. -/
def toXYZ (lab : Lab) : XYZ :=
  let fy := (lab.l + 16.0) / 116.0
  let fx := lab.a / 500.0 + fy
  let fz := fy - lab.b / 200.0
  let x := XYZ.d65_x * fInv fx
  let y := XYZ.d65_y * fInv fy
  let z := XYZ.d65_z * fInv fz
  ⟨x, y, z⟩

/-- Convert sRGB Color to Lab. -/
def fromColor (c : Color) : Lab :=
  fromXYZ (XYZ.fromColor c)

/-- Convert Lab to sRGB Color. -/
def toColor (lab : Lab) (alpha : Float := 1.0) : Color :=
  XYZ.toColor (toXYZ lab) alpha

/-- Create Lab color with clamped lightness. -/
def lab (l a b : Float) : Lab :=
  ⟨if l < 0.0 then 0.0 else if l > 100.0 then 100.0 else l, a, b⟩

end Lab

namespace Color

/-- Convert Color to Lab. -/
def toLab (c : Color) : Lab := Lab.fromColor c

/-- Create Color from Lab, with optional alpha. -/
def fromLab (lab : Lab) (alpha : Float := 1.0) : Color := Lab.toColor lab alpha

end Color

end Tincture
