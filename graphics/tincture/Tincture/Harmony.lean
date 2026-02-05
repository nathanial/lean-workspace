/-
  Tincture - Color Harmony
  Generate harmonious color combinations.
-/

import Tincture.Color
import Tincture.Adjust
import Tincture.Space.HSL
import Tincture.Space.OkLCH

namespace Tincture

/-- Types of color harmony schemes. -/
inductive HarmonyType where
  | complementary      -- Opposite on color wheel (180°)
  | splitComplementary -- Base + two colors adjacent to complement
  | triadic            -- Three colors equally spaced (120°)
  | tetradic           -- Four colors (rectangle on wheel)
  | square             -- Four colors equally spaced (90°)
  | analogous          -- Adjacent colors on wheel
  | monochromatic      -- Single hue, varying lightness/saturation
deriving Repr, BEq, Inhabited

namespace Color

/-- Get the complementary color (opposite on color wheel). -/
def complementary (c : Color) : Color :=
  rotateHue c 0.5

/-- Get split-complementary colors (base + two adjacent to complement).
    Returns (left of complement, right of complement). -/
def splitComplementary (c : Color) (spread : Float := 30.0 / 360.0) : Color × Color :=
  let comp := rotateHue c 0.5
  (rotateHue comp (-spread), rotateHue comp spread)

/-- Get triadic colors (three equally spaced on wheel).
    Returns (clockwise 120°, counterclockwise 120°). -/
def triadic (c : Color) : Color × Color :=
  (rotateHue c (1.0 / 3.0), rotateHue c (2.0 / 3.0))

/-- Get tetradic colors (rectangle on color wheel).
    Returns (complement, other pair color, other pair complement). -/
def tetradic (c : Color) (offset : Float := 60.0 / 360.0) : Color × Color × Color :=
  let c2 := complementary c
  let c3 := rotateHue c offset
  let c4 := complementary c3
  (c2, c3, c4)

/-- Get square colors (four equally spaced on wheel).
    Returns array of 3 additional colors. -/
def square (c : Color) : Array Color :=
  #[rotateHue c 0.25, rotateHue c 0.5, rotateHue c 0.75]

/-- Get analogous colors (adjacent on wheel).
    Returns (left neighbor, right neighbor). -/
def analogous (c : Color) (spread : Float := 30.0 / 360.0) : Color × Color :=
  (rotateHue c (-spread), rotateHue c spread)

/-- Helper to generate array of colors. -/
private def genColors (count : Nat) (f : Nat → Color) : Array Color :=
  let rec go (i : Nat) (acc : Array Color) : Array Color :=
    if i >= count then acc
    else go (i + 1) (acc.push (f i))
  go 0 #[]

/-- Generate monochromatic palette (same hue, varying lightness).
    Returns array of colors from dark to light. -/
def monochromatic (c : Color) (count : Nat) : Array Color :=
  if count == 0 then #[]
  else if count == 1 then #[c]
  else
    let hsl := HSL.fromColor c
    genColors count fun i =>
      let l := 0.1 + 0.8 * (i.toFloat / (count - 1).toFloat)
      HSL.toColor ⟨hsl.h, hsl.s, l⟩ c.a

/-- Generate shades (color mixed with black). -/
def shades (c : Color) (count : Nat) : Array Color :=
  if count == 0 then #[]
  else genColors count fun i =>
    let t := i.toFloat / count.toFloat
    lerp c black t

/-- Generate tints (color mixed with white). -/
def tints (c : Color) (count : Nat) : Array Color :=
  if count == 0 then #[]
  else genColors count fun i =>
    let t := i.toFloat / count.toFloat
    lerp c white t

/-- Generate tones (color mixed with gray). -/
def tones (c : Color) (count : Nat) : Array Color :=
  if count == 0 then #[]
  else genColors count fun i =>
    let t := i.toFloat / count.toFloat
    lerp c (gray 0.5) t

/-- Get harmony colors based on harmony type. -/
def harmony (c : Color) (type : HarmonyType) : Array Color :=
  match type with
  | .complementary =>
    #[c, complementary c]
  | .splitComplementary =>
    let (left, right) := splitComplementary c
    #[c, left, right]
  | .triadic =>
    let (c1, c2) := triadic c
    #[c, c1, c2]
  | .tetradic =>
    let (c1, c2, c3) := tetradic c
    #[c, c1, c2, c3]
  | .square =>
    #[c] ++ square c
  | .analogous =>
    let (left, right) := analogous c
    #[left, c, right]
  | .monochromatic =>
    monochromatic c 5

/-- Generate harmony in OkLCH space (perceptually better). -/
def harmonyOk (c : Color) (type : HarmonyType) : Array Color :=
  let oklch := OkLCH.fromColor c
  let rotateOk (amount : Float) : Color :=
    OkLCH.toColor (OkLCH.rotateHue oklch amount) c.a
  match type with
  | .complementary =>
    #[c, rotateOk 0.5]
  | .splitComplementary =>
    #[c, rotateOk (0.5 - 30.0/360.0), rotateOk (0.5 + 30.0/360.0)]
  | .triadic =>
    #[c, rotateOk (1.0/3.0), rotateOk (2.0/3.0)]
  | .tetradic =>
    #[c, rotateOk 0.5, rotateOk (1.0/6.0), rotateOk (1.0/6.0 + 0.5)]
  | .square =>
    #[c, rotateOk 0.25, rotateOk 0.5, rotateOk 0.75]
  | .analogous =>
    #[rotateOk (-30.0/360.0), c, rotateOk (30.0/360.0)]
  | .monochromatic =>
    genColors 5 fun i =>
      let l := 0.2 + 0.6 * (i.toFloat / 4.0)
      OkLCH.toColor ⟨l, oklch.c, oklch.h⟩ c.a

end Color

end Tincture
