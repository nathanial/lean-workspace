/-
  Property-based tests for Tincture using Plausible.
  These tests verify invariants that should hold for all valid inputs.
-/

import Tincture
import Plausible
import Crucible

namespace TinctureTests.PropertyTests

open Plausible
open Crucible
open Tincture

/-! ## Random Generators for Tincture Types -/

/-- Generate a random Float in [0, 1] range. -/
def genUnitFloat : Gen Float := do
  -- Generate a Nat up to 10000 and divide by 10000 for fine granularity
  let n ← Gen.choose Nat 0 10000 (by omega)
  return n.val.toFloat / 10000.0

/-- Arbitrary instance for generating unit interval floats. -/
structure UnitFloat where
  val : Float
  deriving Repr

instance : Arbitrary UnitFloat where
  arbitrary := do
    let f ← genUnitFloat
    return ⟨f⟩

instance : Shrinkable UnitFloat where
  shrink uf :=
    -- Shrink towards 0 or 1 (boundaries)
    let v := uf.val
    let candidates := [0.0, 1.0, v / 2.0, (v + 1.0) / 2.0].filter (· != v)
    candidates.map (⟨·⟩)

/-- Arbitrary instance for Color. -/
instance : Arbitrary Color where
  arbitrary := do
    let r ← genUnitFloat
    let g ← genUnitFloat
    let b ← genUnitFloat
    let a ← genUnitFloat
    return Color.rgba r g b a

instance : Shrinkable Color where
  shrink c :=
    -- Shrink by reducing individual components towards 0 or standard colors
    let shrinkComponent (x : Float) : List Float :=
      if x == 0.0 then []
      else if x == 1.0 then [0.0]
      else [0.0, 1.0, x / 2.0]
    let rs := shrinkComponent c.r |>.map fun r => Color.rgba r c.g c.b c.a
    let gs := shrinkComponent c.g |>.map fun g => Color.rgba c.r g c.b c.a
    let bs := shrinkComponent c.b |>.map fun b => Color.rgba c.r c.g b c.a
    let as := shrinkComponent c.a |>.map fun a => Color.rgba c.r c.g c.b a
    rs ++ gs ++ bs ++ as

/-- Check if two colors are approximately equal. -/
def colorApproxEq (c1 c2 : Color) (epsilon : Float := 0.02) : Bool :=
  floatNear c1.r c2.r epsilon &&
  floatNear c1.g c2.g epsilon &&
  floatNear c1.b c2.b epsilon

/-! ## Property Tests -/

-- clamp01 output is always in [0, 1]
#test ∀ (uf : UnitFloat),
  let clamped := Color.clamp01 (uf.val * 3.0 - 1.0)  -- test range [-1, 2]
  clamped >= 0.0 ∧ clamped <= 1.0

-- clamp01 is idempotent
#test ∀ (uf : UnitFloat),
  let v := uf.val * 3.0 - 1.0  -- test range [-1, 2]
  let once := Color.clamp01 v
  let twice := Color.clamp01 once
  once == twice

-- lerp at t=0 returns first color
#test ∀ (c1 c2 : Color),
  colorApproxEq (Color.lerp c1 c2 0.0) c1

-- lerp at t=1 returns second color
#test ∀ (c1 c2 : Color),
  colorApproxEq (Color.lerp c1 c2 1.0) c2

-- contrast ratio is symmetric
#test ∀ (c1 c2 : Color),
  let r1 := Color.contrastRatio c1 c2
  let r2 := Color.contrastRatio c2 c1
  floatNear r1 r2 0.01

-- contrast ratio is always >= 1
#test ∀ (c1 c2 : Color),
  Color.contrastRatio c1 c2 >= 1.0

-- contrast ratio is always <= 21
#test ∀ (c1 c2 : Color),
  Color.contrastRatio c1 c2 <= 21.0

-- HSL roundtrip preserves color
#test ∀ (c : Color),
  let roundtrip := HSL.toColor (HSL.fromColor c) c.a
  colorApproxEq roundtrip c 0.03

-- OkLab roundtrip preserves color
#test ∀ (c : Color),
  let roundtrip := OkLab.toColor (OkLab.fromColor c)
  colorApproxEq roundtrip c 0.03

-- luminance is always in [0, 1]
#test ∀ (c : Color),
  let lum := Color.relativeLuminance c
  lum >= 0.0 ∧ lum <= 1.0

-- multiply with white is identity
#test ∀ (c : Color),
  colorApproxEq (Color.multiply c Color.white) c

-- screen with black is identity
#test ∀ (c : Color),
  colorApproxEq (Color.screen c Color.black) c

-- difference of color with itself is black
#test ∀ (c : Color),
  let diff := Color.blend .difference c c
  floatNear diff.r 0.0 0.01 ∧ floatNear diff.g 0.0 0.01 ∧ floatNear diff.b 0.0 0.01

-- hex roundtrip preserves color
#test ∀ (c : Color),
  let hex := Color.toHex c
  let parsed := Color.fromHex hex
  parsed.isSome ∧ (parsed.map (colorApproxEq · c)).getD false

-- complementary of complementary preserves hue
#test ∀ (c : Color),
  let double := Color.complementary (Color.complementary c)
  let origHsl := HSL.fromColor c
  let doubleHsl := HSL.fromColor double
  -- Hue should match (accounting for wraparound at 0/1)
  let hueDiff := Float.abs (origHsl.h - doubleHsl.h)
  hueDiff < 0.02 ∨ hueDiff > 0.98

-- deltaE of color with itself is zero
#test ∀ (c : Color),
  let de := Color.deltaE2000 c c
  floatNear de 0.0 0.001

-- deltaE is symmetric
#test ∀ (c1 c2 : Color),
  let de1 := Color.deltaE2000 c1 c2
  let de2 := Color.deltaE2000 c2 c1
  floatNear de1 de2 0.001

-- deltaE is always non-negative
#test ∀ (c1 c2 : Color),
  Color.deltaE2000 c1 c2 >= 0.0

-- CMYK roundtrip preserves color
#test ∀ (c : Color),
  let roundtrip := CMYK.toColor (CMYK.fromColor c)
  colorApproxEq roundtrip c 0.03

-- gradient sample count is correct
#test ∀ (c1 c2 : Color),
  let grad := Gradient.linear c1 c2
  grad.sample 10 |>.size == 10

-- gradient samples are valid colors
#test ∀ (c1 c2 : Color),
  let grad := Gradient.linear c1 c2
  let samples := grad.sample 5
  samples.all fun c =>
    c.r >= 0.0 ∧ c.r <= 1.0 ∧
    c.g >= 0.0 ∧ c.g <= 1.0 ∧
    c.b >= 0.0 ∧ c.b <= 1.0 ∧
    c.a >= 0.0 ∧ c.a <= 1.0

-- isLight and isDark are opposites
#test ∀ (c : Color),
  Color.isLight c != Color.isDark c

end TinctureTests.PropertyTests
