/-
  Tincture - Color Blending Operations
  Standard blend modes used in graphics software.
-/

import Tincture.Color
import Tincture.Space.HSL
import Tincture.Space.OkLab
import Tincture.Space.OkLCH

namespace Tincture

/-- Standard blend modes as used in graphics software. -/
inductive BlendMode where
  | normal      -- Top layer only (respects alpha)
  | multiply    -- Darkens: a * b
  | screen      -- Lightens: 1 - (1-a)(1-b)
  | overlay     -- Combines multiply and screen
  | darken      -- min(a, b)
  | lighten     -- max(a, b)
  | colorDodge  -- Brightens base by top
  | colorBurn   -- Darkens base by top
  | hardLight   -- Like overlay but reversed
  | softLight   -- Gentler than hard light
  | difference  -- |a - b|
  | exclusion   -- Similar to difference, lower contrast
  | hue         -- Hue from top, sat/lum from base
  | saturation  -- Sat from top, hue/lum from base
  | color       -- Hue and sat from top, lum from base
  | luminosity  -- Lum from top, hue/sat from base
deriving Repr, BEq, Inhabited

namespace BlendMode

/-- Apply blend mode to a single channel. -/
private def blendChannel (mode : BlendMode) (base top : Float) : Float :=
  match mode with
  | .normal => top
  | .multiply => base * top
  | .screen => 1.0 - (1.0 - base) * (1.0 - top)
  | .overlay =>
    if base < 0.5 then 2.0 * base * top
    else 1.0 - 2.0 * (1.0 - base) * (1.0 - top)
  | .darken => Float.min base top
  | .lighten => Float.max base top
  | .colorDodge =>
    if top >= 1.0 then 1.0
    else Float.min 1.0 (base / (1.0 - top))
  | .colorBurn =>
    if top <= 0.0 then 0.0
    else Float.max 0.0 (1.0 - (1.0 - base) / top)
  | .hardLight =>
    if top < 0.5 then 2.0 * base * top
    else 1.0 - 2.0 * (1.0 - base) * (1.0 - top)
  | .softLight =>
    if top < 0.5 then
      base - (1.0 - 2.0 * top) * base * (1.0 - base)
    else
      let d := if base <= 0.25 then
        ((16.0 * base - 12.0) * base + 4.0) * base
      else
        Float.sqrt base
      base + (2.0 * top - 1.0) * (d - base)
  | .difference => Float.abs (base - top)
  | .exclusion => base + top - 2.0 * base * top
  -- Complex modes handled separately
  | .hue | .saturation | .color | .luminosity => top

end BlendMode

namespace Color

/-- Blend two colors using the specified blend mode.
    Base is the bottom layer, top is the layer being applied. -/
def blend (mode : BlendMode) (base top : Color) : Color :=
  match mode with
  | .hue =>
    -- Use hue from top, saturation and lightness from base
    let baseHsl := HSL.fromColor base
    let topHsl := HSL.fromColor top
    HSL.toColor ⟨topHsl.h, baseHsl.s, baseHsl.l⟩ base.a
  | .saturation =>
    -- Use saturation from top, hue and lightness from base
    let baseHsl := HSL.fromColor base
    let topHsl := HSL.fromColor top
    HSL.toColor ⟨baseHsl.h, topHsl.s, baseHsl.l⟩ base.a
  | .color =>
    -- Use hue and saturation from top, lightness from base
    let baseHsl := HSL.fromColor base
    let topHsl := HSL.fromColor top
    HSL.toColor ⟨topHsl.h, topHsl.s, baseHsl.l⟩ base.a
  | .luminosity =>
    -- Use lightness from top, hue and saturation from base
    let baseHsl := HSL.fromColor base
    let topHsl := HSL.fromColor top
    HSL.toColor ⟨baseHsl.h, baseHsl.s, topHsl.l⟩ base.a
  | _ =>
    let r := BlendMode.blendChannel mode base.r top.r
    let g := BlendMode.blendChannel mode base.g top.g
    let b := BlendMode.blendChannel mode base.b top.b
    ⟨clamp01 r, clamp01 g, clamp01 b, base.a⟩

/-- Blend with alpha compositing (Porter-Duff source-over). -/
def blendAlpha (mode : BlendMode) (base top : Color) : Color :=
  if top.a <= 0.0 then base
  else if top.a >= 1.0 then blend mode base top
  else if base.a <= 0.0 then top
  else
    -- Alpha compositing
    let outA := top.a + base.a * (1.0 - top.a)
    if outA <= 0.0 then transparent
    else
      let blended := blend mode base top
      let r := (top.a * blended.r + base.a * base.r * (1.0 - top.a)) / outA
      let g := (top.a * blended.g + base.a * base.g * (1.0 - top.a)) / outA
      let b := (top.a * blended.b + base.a * base.b * (1.0 - top.a)) / outA
      ⟨clamp01 r, clamp01 g, clamp01 b, outA⟩

/-- Mix two colors by ratio (0.0 = first color, 1.0 = second color).
    Simple linear interpolation in sRGB space. -/
def mix (c1 c2 : Color) (ratio : Float := 0.5) : Color :=
  lerp c1 c2 ratio

/-- Mix colors in OkLab space (perceptually uniform mixing). -/
def mixOkLab (c1 c2 : Color) (ratio : Float := 0.5) : Color :=
  lerpOkLab c1 c2 ratio

/-- Mix colors in OkLCH space (preserves hue better). -/
def mixOkLCH (c1 c2 : Color) (ratio : Float := 0.5) : Color :=
  lerpOkLCH c1 c2 ratio

/-- Multiply blend (shorthand). -/
def multiply (base top : Color) : Color := blend .multiply base top

/-- Screen blend (shorthand). -/
def screen (base top : Color) : Color := blend .screen base top

/-- Overlay blend (shorthand). -/
def overlay (base top : Color) : Color := blend .overlay base top

/-- Composite top over base with alpha. -/
def over (base top : Color) : Color :=
  blendAlpha .normal base top

end Color

end Tincture
