/-
  Tincture - Gradient Generation
  Multi-stop color gradients with interpolation in various color spaces.
-/

import Tincture.Color
import Tincture.Space.OkLab
import Tincture.Space.OkLCH
import Tincture.Space.HSL
import Tincture.Space.RGB

namespace Tincture

/-- A color stop in a gradient. -/
structure ColorStop where
  color : Color
  position : Float  -- 0.0 to 1.0
deriving Repr, BEq, Inhabited

/-- Interpolation space for gradients. -/
inductive GradientSpace where
  | sRGB      -- Linear interpolation in sRGB (can produce dull midpoints)
  | linearRGB -- Interpolation in linear RGB (physically accurate light mixing)
  | oklab     -- OkLab interpolation (perceptually uniform, smooth)
  | oklch     -- OkLCH interpolation (perceptually uniform, preserves hue)
  | hsl       -- HSL interpolation (can have hue discontinuities)
deriving Repr, BEq, Inhabited

/-- Hue interpolation method for polar color spaces. -/
inductive HueMethod where
  | shorter     -- Take shorter path around hue wheel (default)
  | longer      -- Take longer path
  | increasing  -- Always increase hue (clockwise)
  | decreasing  -- Always decrease hue (counterclockwise)
deriving Repr, BEq, Inhabited

/-- A color gradient with multiple stops. -/
structure Gradient where
  stops : Array ColorStop
  space : GradientSpace := .oklab
  hueMethod : HueMethod := .shorter
deriving Repr, Inhabited

namespace Gradient

/-- Create a simple two-color gradient. -/
def linear (c1 c2 : Color) (space : GradientSpace := .oklab) : Gradient :=
  { stops := #[⟨c1, 0.0⟩, ⟨c2, 1.0⟩], space }

/-- Create a gradient from an array of colors (evenly distributed). -/
def fromColors (colors : Array Color) (space : GradientSpace := .oklab) : Gradient :=
  if colors.isEmpty then
    { stops := #[], space }
  else if colors.size == 1 then
    { stops := #[⟨colors[0]!, 0.0⟩, ⟨colors[0]!, 1.0⟩], space }
  else
    let rec buildStops (i : Nat) (acc : Array ColorStop) : Array ColorStop :=
      if i >= colors.size then acc
      else buildStops (i + 1) (acc.push ⟨colors[i]!, i.toFloat / (colors.size - 1).toFloat⟩)
    { stops := buildStops 0 #[], space }

/-- Create a gradient with explicit stop positions. -/
def fromStops (stops : Array ColorStop) (space : GradientSpace := .oklab) : Gradient :=
  -- Sort stops by position
  let sorted := stops.qsort (·.position < ·.position)
  { stops := sorted, space }

/-- Interpolate hue based on method. -/
private def interpolateHue (h1 h2 t : Float) (method : HueMethod) : Float :=
  let diff := h2 - h1
  let adjustedDiff := match method with
    | .shorter =>
      if diff > 0.5 then diff - 1.0
      else if diff < -0.5 then diff + 1.0
      else diff
    | .longer =>
      if diff > 0.0 && diff < 0.5 then diff - 1.0
      else if diff < 0.0 && diff > -0.5 then diff + 1.0
      else diff
    | .increasing =>
      if diff < 0.0 then diff + 1.0 else diff
    | .decreasing =>
      if diff > 0.0 then diff - 1.0 else diff
  let result := h1 + adjustedDiff * t
  -- Normalize to [0, 1)
  result - result.floor

/-- Interpolate between two colors in the given space. -/
private def interpolateColors (c1 c2 : Color) (t : Float) (space : GradientSpace) (hueMethod : HueMethod) : Color :=
  match space with
  | .sRGB =>
    Color.lerp c1 c2 t
  | .linearRGB =>
    let rgb1 := LinearRGB.fromColor c1
    let rgb2 := LinearRGB.fromColor c2
    let result := LinearRGB.lerp rgb1 rgb2 t
    let c := LinearRGB.toColor result
    let a := c1.a + (c2.a - c1.a) * t
    ⟨c.r, c.g, c.b, a⟩
  | .oklab =>
    Color.lerpOkLab c1 c2 t
  | .oklch =>
    let lch1 := OkLCH.fromColor c1
    let lch2 := OkLCH.fromColor c2
    let l := lch1.l + (lch2.l - lch1.l) * t
    let c := lch1.c + (lch2.c - lch1.c) * t
    let h := interpolateHue lch1.h lch2.h t hueMethod
    let a := c1.a + (c2.a - c1.a) * t
    let result := OkLCH.toColor ⟨l, c, h⟩
    ⟨result.r, result.g, result.b, a⟩
  | .hsl =>
    let hsl1 := HSL.fromColor c1
    let hsl2 := HSL.fromColor c2
    let h := interpolateHue hsl1.h hsl2.h t hueMethod
    let s := hsl1.s + (hsl2.s - hsl1.s) * t
    let l := hsl1.l + (hsl2.l - hsl1.l) * t
    let a := c1.a + (c2.a - c1.a) * t
    let result := HSL.toColor ⟨h, s, l⟩
    ⟨result.r, result.g, result.b, a⟩

/-- Get the color at position t (0.0 to 1.0) in the gradient. -/
def colorAt (g : Gradient) (t : Float) : Color :=
  if g.stops.isEmpty then Color.transparent
  else if g.stops.size == 1 then g.stops[0]!.color
  else
    let t := Color.clamp01 t
    -- Find the two stops to interpolate between
    let rec findStops (i : Nat) (lower upper : ColorStop) : ColorStop × ColorStop :=
      if i >= g.stops.size then (lower, upper)
      else
        let stop := g.stops[i]!
        let lower' := if stop.position <= t then stop else lower
        let upper' := if stop.position >= t && stop.position < upper.position then stop else upper
        findStops (i + 1) lower' upper'
    let (lower, upper) := findStops 0 g.stops[0]! g.stops[g.stops.size - 1]!
    if lower.position >= upper.position then
      lower.color
    else
      let localT := (t - lower.position) / (upper.position - lower.position)
      interpolateColors lower.color upper.color localT g.space g.hueMethod

/-- Sample the gradient at n evenly-spaced points. -/
def sample (g : Gradient) (count : Nat) : Array Color :=
  if count == 0 then #[]
  else if count == 1 then #[g.colorAt 0.5]
  else
    let rec go (i : Nat) (acc : Array Color) : Array Color :=
      if i >= count then acc
      else
        let t := i.toFloat / (count - 1).toFloat
        go (i + 1) (acc.push (g.colorAt t))
    go 0 #[]

/-- Reverse the gradient. -/
def reverse (g : Gradient) : Gradient :=
  let stops := g.stops.map fun s => ⟨s.color, 1.0 - s.position⟩
  { g with stops := stops.reverse }

end Gradient

-- Common gradients
namespace Gradients

/-- Rainbow gradient (ROYGBIV). -/
def rainbow : Gradient :=
  Gradient.fromColors #[
    Color.red,
    Color.orange,
    Color.yellow,
    Color.green,
    Color.blue,
    ⟨0.29, 0.0, 0.51, 1.0⟩,  -- Indigo
    ⟨0.56, 0.0, 1.0, 1.0⟩    -- Violet
  ] .oklch

/-- Grayscale gradient (black to white). -/
def grayscale : Gradient :=
  Gradient.linear Color.black Color.white .sRGB

/-- Heat map gradient (blue -> cyan -> green -> yellow -> red). -/
def heatMap : Gradient :=
  Gradient.fromColors #[
    Color.blue,
    Color.cyan,
    Color.green,
    Color.yellow,
    Color.red
  ] .oklab

end Gradients

end Tincture
