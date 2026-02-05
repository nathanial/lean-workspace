/-
  Tincture - Palette Generation
  Generate color palettes for various use cases.
-/

import Tincture.Color
import Tincture.Space.OkLCH
import Tincture.Harmony
import Tincture.Gradient

namespace Tincture

namespace Palette

/-- Helper to generate array of colors using recursion. -/
private def genColors (count : Nat) (f : Nat → Color) : Array Color :=
  let rec go (i : Nat) (acc : Array Color) : Array Color :=
    if i >= count then acc
    else go (i + 1) (acc.push (f i))
  go 0 #[]

/-- Generate a sequential palette (light to dark or vice versa).
    Good for representing continuous data. -/
def sequential (baseColor : Color) (count : Nat) (lightToDark : Bool := true) : Array Color :=
  if count == 0 then #[]
  else if count == 1 then #[baseColor]
  else
    let lch := OkLCH.fromColor baseColor
    genColors count fun i =>
      let t := i.toFloat / (count - 1).toFloat
      let l := if lightToDark then 0.95 - t * 0.7 else 0.25 + t * 0.7
      -- Adjust chroma slightly for darker colors
      let c := lch.c * (0.5 + 0.5 * l)
      OkLCH.toColor ⟨l, c, lch.h⟩ baseColor.a

/-- Helper for building gradient samples -/
private def sampleGradient (grad : Gradient) (count : Nat) (offset : Float) (scale : Float) : Array Color :=
  let rec go (i : Nat) (acc : Array Color) : Array Color :=
    if i >= count then acc
    else
      let t := offset + (i.toFloat + scale) / count.toFloat
      go (i + 1) (acc.push (grad.colorAt t))
  go 0 #[]

/-- Generate a diverging palette (two colors meeting at a neutral midpoint).
    Good for data with a meaningful midpoint. -/
def diverging (lowColor highColor : Color) (count : Nat) (midColor : Color := Color.white) : Array Color :=
  if count == 0 then #[]
  else if count == 1 then #[midColor]
  else if count == 2 then #[lowColor, highColor]
  else
    let mid := count / 2
    let hasCenter := count % 2 == 1
    let lowGrad := Gradient.linear lowColor midColor .oklab
    let highGrad := Gradient.linear midColor highColor .oklab

    -- Build lower half
    let lower := sampleGradient lowGrad mid 0.0 0.0

    -- Add center if odd count
    let withMid := if hasCenter then lower.push midColor else lower

    -- Build upper half
    let upperCount := count - withMid.size
    let upper := sampleGradient highGrad upperCount 0.0 1.0

    withMid ++ upper

/-- Generate a qualitative palette (distinct colors for categories).
    Uses golden angle to maximize perceptual difference. -/
def qualitative (count : Nat) (saturation : Float := 0.7) (lightness : Float := 0.6) : Array Color :=
  if count == 0 then #[]
  else
    let goldenAngle := 0.381966  -- Golden ratio - 1
    genColors count fun i =>
      let h := (i.toFloat * goldenAngle) - (i.toFloat * goldenAngle).floor
      OkLCH.toColor ⟨lightness, saturation * 0.3, h⟩ 1.0

/-- Generate a palette from a harmony type. -/
def fromHarmony (baseColor : Color) (harmony : HarmonyType) : Array Color :=
  Color.harmonyOk baseColor harmony

/-- Generate a monochromatic palette (single hue, varying lightness/saturation). -/
def monochromatic (baseColor : Color) (count : Nat) : Array Color :=
  Color.monochromatic baseColor count

/-- Generate shades of a color (progressively darker). -/
def shades (baseColor : Color) (count : Nat) : Array Color :=
  Color.shades baseColor count

/-- Generate tints of a color (progressively lighter). -/
def tints (baseColor : Color) (count : Nat) : Array Color :=
  Color.tints baseColor count

/-- Generate tones of a color (progressively more gray). -/
def tones (baseColor : Color) (count : Nat) : Array Color :=
  Color.tones baseColor count

/-- A simple pseudo-random number generator for deterministic results. -/
private def lcg (seed : UInt64) : UInt64 :=
  (seed * 6364136223846793005 + 1442695040888963407)

/-- Generate a random color from a seed, returning (color, nextSeed). -/
private def randomColorFromSeed (seed : UInt64) : Color × UInt64 :=
  let s1 := lcg seed
  let h := (s1.toFloat / UInt64.size.toFloat)
  let s2 := lcg s1
  let c := 0.1 + 0.2 * (s2.toFloat / UInt64.size.toFloat)
  let s3 := lcg s2
  let l := 0.3 + 0.5 * (s3.toFloat / UInt64.size.toFloat)
  (OkLCH.toColor ⟨l, c, h⟩ 1.0, s3)

/-- Generate random colors with good distribution. -/
def random (count : Nat) (seed : UInt64 := 12345) : Array Color :=
  if count == 0 then #[]
  else
    let rec go (i : Nat) (s : UInt64) (acc : Array Color) : Array Color :=
      if i >= count then acc
      else
        let (color, nextSeed) := randomColorFromSeed s
        go (i + 1) nextSeed (acc.push color)
    go 0 seed #[]

/-- Generate a palette optimized for accessibility (distinguishable by colorblind users).
    Uses colors that remain distinct under common forms of color blindness. -/
def accessible (count : Nat) : Array Color :=
  -- Paul Tol's colorblind-friendly palette
  let tolColors := #[
    Color.fromRgb8 0 119 187,     -- Blue
    Color.fromRgb8 51 187 238,    -- Cyan
    Color.fromRgb8 0 153 136,     -- Teal
    Color.fromRgb8 238 119 51,    -- Orange
    Color.fromRgb8 204 51 17,     -- Red
    Color.fromRgb8 238 51 119,    -- Magenta
    Color.fromRgb8 187 187 187,   -- Grey
    Color.fromRgb8 153 153 51,    -- Olive
    Color.fromRgb8 136 34 85,     -- Wine
    Color.fromRgb8 102 17 0       -- Brown
  ]
  if count == 0 then #[]
  else if count <= tolColors.size then
    tolColors.toSubarray 0 count |>.toArray
  else
    -- If we need more, generate additional colors
    let extra := qualitative (count - tolColors.size)
    tolColors ++ extra

/-- Generate a warm palette (reds, oranges, yellows). -/
def warm (count : Nat) : Array Color :=
  if count == 0 then #[]
  else
    genColors count fun i =>
      let t := i.toFloat / count.toFloat
      let h := t * 0.15  -- Range from red (0) to yellow-ish (0.15)
      OkLCH.toColor ⟨0.65, 0.2, h⟩ 1.0

/-- Generate a cool palette (blues, greens, purples). -/
def cool (count : Nat) : Array Color :=
  if count == 0 then #[]
  else
    genColors count fun i =>
      let t := i.toFloat / count.toFloat
      let h := 0.5 + t * 0.25  -- Range from cyan (0.5) to purple-ish (0.75)
      OkLCH.toColor ⟨0.55, 0.15, h⟩ 1.0

/-- Generate an earth tones palette (browns, tans, olive). -/
def earth (count : Nat) : Array Color :=
  if count == 0 then #[]
  else
    let earthColors := #[
      Color.fromRgb8 139 90 43,   -- Saddle brown
      Color.fromRgb8 160 82 45,   -- Sienna
      Color.fromRgb8 188 143 143, -- Rosy brown
      Color.fromRgb8 210 180 140, -- Tan
      Color.fromRgb8 128 128 0,   -- Olive
      Color.fromRgb8 85 107 47,   -- Dark olive green
      Color.fromRgb8 107 142 35,  -- Olive drab
      Color.fromRgb8 189 183 107  -- Dark khaki
    ]
    if count <= earthColors.size then
      earthColors.toSubarray 0 count |>.toArray
    else
      -- Interpolate to get more colors
      let grad := Gradient.fromColors earthColors .oklab
      grad.sample count

/-- Generate a pastel palette (soft, light colors). -/
def pastel (count : Nat) : Array Color :=
  if count == 0 then #[]
  else
    let goldenAngle := 0.381966
    genColors count fun i =>
      let h := (i.toFloat * goldenAngle) - (i.toFloat * goldenAngle).floor
      OkLCH.toColor ⟨0.85, 0.08, h⟩ 1.0

/-- Generate a neon/vibrant palette. -/
def neon (count : Nat) : Array Color :=
  if count == 0 then #[]
  else
    let goldenAngle := 0.381966
    genColors count fun i =>
      let h := (i.toFloat * goldenAngle) - (i.toFloat * goldenAngle).floor
      OkLCH.toColor ⟨0.7, 0.35, h⟩ 1.0

end Palette

end Tincture
